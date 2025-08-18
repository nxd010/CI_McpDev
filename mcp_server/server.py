from mcp.server.fastmcp import FastMCP
import requests
import base64
from configs import *


mcp = FastMCP(
    name="Jenkins-MCP-Server",
)

# --- Tool Definition ---
@mcp.tool(description="Call this tool to fetch the status and details of a specific Jenkins build given the build url")
def get_jenkins_build_status(build_url: str) -> dict:    
    credentials = f"{JENKINS_USER}:{JENKINS_TOKEN}"
    encoded_credentials = base64.b64encode(credentials.encode()).decode()
    headers = {
        "Authorization": f"Basic {encoded_credentials}"
    }

    try:
        if not build_url.endswith('/api/json'):
            api_url = build_url.rstrip('/') + '/api/json'
        else:
            api_url = build_url

        response = requests.get(api_url, headers=headers)
        response.raise_for_status()
        build_data = response.json()
        
        print(f"Successfully fetched status for build {build_data.get('number')}: {build_data.get('result')}")
        
        return {
            "build_number": build_data.get("number"),
            "status": build_data.get("result"),
            "building": build_data.get("building"),
            "url": build_data.get("url"),
            "timestamp": build_data.get("timestamp"),
            "message": "Successfully fetched build status.",
        }
    except requests.exceptions.RequestException as e:
        print(f"Error fetching build status: {e}")
        return {
            "error": "Failed to connect to Jenkins API.",
            "details": str(e),
            "url": api_url
        }
    except Exception as e:
        print(f"An unexpected error occurred: {e}")
        return {
            "error": "An unexpected error occurred.",
            "details": str(e),
            "url": api_url
        }


if __name__ == "__main__":
    print("Starting FastMCP server for Jenkins monitoring...")
    print(f"To run, ensure JENKINS_USER and JENKINS_TOKEN are set in your .env file.")
    mcp.run(transport="stdio")