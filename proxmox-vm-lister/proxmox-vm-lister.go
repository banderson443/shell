package main

import (
	"crypto/tls"
	"encoding/json"
	"flag"
	"fmt"
	"io/ioutil"
	"net/http"
	"net/url"
	"os"
	"strings"
)

// ProxmoxAuth contains authentication information
type ProxmoxAuth struct {
	Hostname string
	Username string
	Password string
	Realm    string
}

// AuthResponse represents the ticket authentication response
type AuthResponse struct {
	Data struct {
		Ticket   string `json:"ticket"`
		CSRFToken string `json:"CSRFPreventionToken"`
	} `json:"data"`
}

// VMData represents the VM information returned from the API
type VMData struct {
	Data []struct {
		VMID   int    `json:"vmid"`
		Name   string `json:"name"`
		Status string `json:"status"`
		Type   string `json:"type"`
		CPU    float64 `json:"cpu"`
		Mem    int64   `json:"mem"`
		MaxMem int64   `json:"maxmem"`
		Disk   int64   `json:"disk"`
		MaxDisk int64  `json:"maxdisk"`
	} `json:"data"`
}

func main() {
	// Parse command line flags
	hostname := flag.String("host", "", "Proxmox host (e.g., https://proxmox.example.com:8006)")
	username := flag.String("user", "", "Proxmox username")
	password := flag.String("password", "", "Proxmox password")
	realm := flag.String("realm", "pam", "Authentication realm (default: pam)")
	insecure := flag.Bool("insecure", false, "Skip SSL verification")
	showRunningOnly := flag.Bool("running-only", true, "Show only running VMs")
	flag.Parse()

	// Check required parameters
	if *hostname == "" || *username == "" || *password == "" {
		fmt.Println("Error: hostname, username, and password are required")
		flag.Usage()
		os.Exit(1)
	}

	// Create auth struct
	auth := ProxmoxAuth{
		Hostname: *hostname,
		Username: *username,
		Password: *password,
		Realm:    *realm,
	}

	// Configure HTTP client with TLS settings
	tr := &http.Transport{
		TLSClientConfig: &tls.Config{InsecureSkipVerify: *insecure},
	}
	client := &http.Client{Transport: tr}

	// Get authentication ticket
	ticket, csrfToken, err := getAuthTicket(client, auth)
	if err != nil {
		fmt.Printf("Authentication error: %v\n", err)
		os.Exit(1)
	}

	// Get VM data
	vms, err := getVMs(client, auth.Hostname, ticket, csrfToken)
	if err != nil {
		fmt.Printf("Error getting VM data: %v\n", err)
		os.Exit(1)
	}

	// Display VM information
	fmt.Println("Virtual Machines on Proxmox Host:")
	fmt.Println("--------------------------------")
	fmt.Printf("%-6s %-30s %-10s %-10s %-10s %-15s\n",
		"VMID", "Name", "Status", "Type", "CPU", "Memory (MB)")
	fmt.Println(strings.Repeat("-", 85))

	count := 0
	for _, vm := range vms.Data {
		// Filter to only show running VMs if requested
		if *showRunningOnly && vm.Status != "running" {
			continue
		}
		
		// Memory in MB
		memoryMB := vm.Mem / (1024 * 1024)
		
		fmt.Printf("%-6d %-30s %-10s %-10s %-10.2f %-15d\n",
			vm.VMID, vm.Name, vm.Status, vm.Type, vm.CPU, memoryMB)
		count++
	}

	fmt.Println(strings.Repeat("-", 85))
	if *showRunningOnly {
		fmt.Printf("Total running VMs: %d\n", count)
	} else {
		fmt.Printf("Total VMs: %d\n", count)
	}
}

// getAuthTicket obtains an authentication ticket from Proxmox API
func getAuthTicket(client *http.Client, auth ProxmoxAuth) (string, string, error) {
	apiURL := fmt.Sprintf("%s/api2/json/access/ticket", auth.Hostname)
	
	data := url.Values{}
	data.Set("username", auth.Username)
	data.Set("password", auth.Password)
	data.Set("realm", auth.Realm)

	req, err := http.NewRequest("POST", apiURL, strings.NewReader(data.Encode()))
	if err != nil {
		return "", "", err
	}
	
	req.Header.Add("Content-Type", "application/x-www-form-urlencoded")
	
	resp, err := client.Do(req)
	if err != nil {
		return "", "", err
	}
	defer resp.Body.Close()

	if resp.StatusCode != http.StatusOK {
		return "", "", fmt.Errorf("authentication failed with status: %s", resp.Status)
	}

	body, err := ioutil.ReadAll(resp.Body)
	if err != nil {
		return "", "", err
	}

	var authResp AuthResponse
	if err := json.Unmarshal(body, &authResp); err != nil {
		return "", "", err
	}

	return authResp.Data.Ticket, authResp.Data.CSRFToken, nil
}

// getVMs gets information about virtual machines from the Proxmox API
func getVMs(client *http.Client, hostname, ticket, csrfToken string) (VMData, error) {
	var vmData VMData
	
	apiURL := fmt.Sprintf("%s/api2/json/cluster/resources?type=vm", hostname)
	
	req, err := http.NewRequest("GET", apiURL, nil)
	if err != nil {
		return vmData, err
	}
	
	// Add authentication cookie
	cookie := &http.Cookie{
		Name:  "PVEAuthCookie",
		Value: ticket,
	}
	req.AddCookie(cookie)
	
	// Add CSRF token if needed (for modification requests, not typically needed for GET)
	if csrfToken != "" {
		req.Header.Add("CSRFPreventionToken", csrfToken)
	}
	
	resp, err := client.Do(req)
	if err != nil {
		return vmData, err
	}
	defer resp.Body.Close()

	if resp.StatusCode != http.StatusOK {
		return vmData, fmt.Errorf("API request failed with status: %s", resp.Status)
	}

	body, err := ioutil.ReadAll(resp.Body)
	if err != nil {
		return vmData, err
	}

	if err := json.Unmarshal(body, &vmData); err != nil {
		return vmData, err
	}

	return vmData, nil
}
