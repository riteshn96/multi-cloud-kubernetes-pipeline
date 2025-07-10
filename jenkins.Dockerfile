# Start from the official, stable Jenkins image
FROM jenkins/jenkins:lts-jdk11

# Switch to the root user to install packages
USER root

# Install dependencies and the Docker CLI client
RUN apt-get update && apt-get install -y lsb-release curl gpg
RUN curl -fsSL https://download.docker.com/linux/debian/gpg | gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
RUN echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/debian $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null
RUN apt-get update && apt-get install -y docker-ce-cli

# --- FIX-STEP 1: Create the 'docker' group ---
# The docker-ce-cli package does not create this group, so we must create it manually.
# We assign a specific Group ID (GID) of 999. This helps avoid conflicts.
RUN groupadd -g 999 docker

# --- FIX-STEP 2: Add the 'jenkins' user to the 'docker' group ---
# Now that the group exists, we can add the jenkins user to it.
RUN usermod -aG docker jenkins

# Switch back to the non-root 'jenkins' user
USER jenkins