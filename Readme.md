<img width="1312" height="857" alt="image" src="https://github.com/user-attachments/assets/216c71b8-88c0-40d6-9c8b-6a6090b3cc70" /># MCP Server to Monitor CI (Continuous Integration) builds

This project aims to demonstrate (as a POC) how we can use MCP Servers to feed real time CI Build context to the IDE and use AI Agents for on the fly status monitoring and context based quick code fixes.
The aim of such tool is to enhance the developer experience and cut the time involved in juggling between different tabs

## Requirements 
  1. Docker
  2. Git
  3. Ngrok

(If Docker Desktop or setup guide has issues running on Windows systems, its recommended to use the setup in wsl)

## Steps to Setup Locally 

1. Fork the repository 
2. Clone the forked repository
3. In project directory run command: `make check_deps`
4. If any dependency is not installed fulfill the requirement
5. Then run command: `make ci-up`
6. This command will get the Jenkins running on  `localhost:8080`
7. Run command `docker logs contrihub-jenkins`
8. Copy the admin password to clipboard
9. Open localhost:8080 on browser
10. Enter the password
11. Choose Install Suggested Plugins
12. Back in terminal run following command on another instance of the terminal: `make ip-tunnel`
13. This will provide you the public IP endpoint of the localhost:8080
14. In the forked repository on github, go to repository settings and then webhooks
15. Create a webhook and enter this public_IP_endpoint/github-webhook/ as webhook url
16. Open the jenkins portal on browser and under the manage jenkins (settings icon) click on plugins
17. Install following plugins by searching in available plugins:
      a. github integration
      b. docker pipeline
18. Configure a new job by clicking on jenkins icon and selecting add new job
19. In configuration page, under triggers select Github hook trigger for GITScm Polling
20. Under Pipeline select the dropdown option as Pipeline script from SCM
<img width="1312" height="857" alt="image" src="https://github.com/user-attachments/assets/9eb88177-7615-4a1a-8070-4986ec4cb115" />

21. Under SCM Dropdown select git
22. Add repository URL
23. Select add credentials and add your github username and in password add your PAT token (generated on github.com)
24. Select the added credential by dropdown showing none
25. Make a code change and push your code to github, the build should trigger


## Objective 
Create the MCP Server with logic to fetch build status and incase of failure fetch the build logs and provide as context to LLM
At the end of project, the build must run and succeed 

## Resources
1. MCP - https://modelcontextprotocol.io/docs/getting-started/intro
2. Jenkins - https://www.jenkins.io/
3. WSL - https://learn.microsoft.com/en-us/windows/wsl/install
4. Docker - https://www.docker.com/
5. Ngrok - https://ngrok.com/
6. CI - https://aws.amazon.com/what-is/ci-cd/
7. Cloud Native Mindset - https://dev.to/aws-builders/embracing-cloud-native-mindset-1fi8
