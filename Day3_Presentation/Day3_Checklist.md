# Activity Checklist - Day 3: Final Presentation

## 1. Deliverables Preparation
- [ ] Ensure the architecture diagram (Lucidchart) is updated with the actual implementation.
- [ ] Ensure the `Blueprint_Draft.md` is complete and reflects the decisions made and configurations applied.
- [ ] Export the CI/CD pipeline code (APIOps) and the YAML/JSON manifests used.
- [ ] Compile everything into a zip file or folder ready to send.

## 2. Demonstration Preparation (Video)
- [ ] Review the `Presentation_Script.md` and adapt it to your style.
- [ ] **Dry-run:**
  - [ ] Start your Docker Desktop local Kubernetes cluster.
  - [ ] Run `./deploy_local_k8s.sh` to spin up the Data Planes via Helm.
  - [ ] Verify that Konnect is displaying metrics correctly.
  - [ ] Verify that the GitHub Actions pipeline runs without errors when modifying an OAS.
  - [ ] Test consuming the Accounts API (with Postman/curl) with valid and invalid credentials.
  - [ ] Test the AI API (Fraud) and validate that the traffic successfully routes to the LLM.
  - [ ] Review that the Developer Portal is accessible and displays the API.

## 3. Recording and Submission
- [ ] Start screen recording (ensure audio and screen are captured well).
- [ ] Perform the theoretical introduction and explain the architecture (based on the Blueprint).
- [ ] Perform the live technical demonstration following the script.
- [ ] Mention the "Next Steps" or outstanding items (Next Actions).
- [ ] Send the email with the attached deliverables and the link to the presentation video to the Kong evaluators within the deadline week.
