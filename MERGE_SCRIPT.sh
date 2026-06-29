#!/bin/bash

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Configuration
GITHUB_USERNAME="ManP2006"
WORK_DIR="$HOME/lab-merge-work"
NEW_REPO_NAME="LAB_WORK"

echo -e "${YELLOW}=== LAB Repository Merger Script ===${NC}"
echo -e "${YELLOW}This script will merge LAB-1 to LAB-12 into a single LAB_WORK repository${NC}\n"

# Step 1: Create working directory
echo -e "${GREEN}[Step 1] Creating working directory...${NC}"
mkdir -p "$WORK_DIR"
cd "$WORK_DIR"

# Step 2: Clone the LAB_WORK repository (or create it if it doesn't exist)
echo -e "${GREEN}[Step 2] Setting up LAB_WORK repository...${NC}"

if [ -d "$NEW_REPO_NAME" ]; then
    echo -e "${YELLOW}LAB_WORK directory already exists. Removing and re-cloning...${NC}"
    rm -rf "$NEW_REPO_NAME"
fi

# You'll need to create LAB_WORK manually on GitHub first, then uncomment:
git clone https://github.com/$GITHUB_USERNAME/$NEW_REPO_NAME.git
cd "$NEW_REPO_NAME"

# Step 3: Add all LAB repositories as remotes and merge them
echo -e "${GREEN}[Step 3] Adding LAB repositories as remotes and merging...${NC}"

for i in {1..12}; do
    LAB_NAME="LAB-$i"
    echo -e "${YELLOW}Processing $LAB_NAME...${NC}"
    
    # Add remote
    git remote add $LAB_NAME https://github.com/$GITHUB_USERNAME/$LAB_NAME.git
    
    # Fetch from the remote
    BRANCH=$(git ls-remote --heads https://github.com/$GITHUB_USERNAME/$LAB_NAME.git | head -1 | awk '{print $2}' | sed 's|refs/heads/||')
    
    if [ -z "$BRANCH" ]; then
        echo -e "${RED}Error: Could not determine default branch for $LAB_NAME${NC}"
        BRANCH="main"
    fi
    
    echo -e "${YELLOW}Using branch: $BRANCH for $LAB_NAME${NC}"
    
    git fetch $LAB_NAME $BRANCH
    
    # Add as subtree
    git subtree add --prefix=$LAB_NAME $LAB_NAME $BRANCH --squash
    
    echo -e "${GREEN}✓ $LAB_NAME merged successfully${NC}\n"
done

# Step 4: Create initial README
echo -e "${GREEN}[Step 4] Creating README...${NC}"
cat > README.md << 'EOF'
# LAB Work Repository

This repository contains all LAB assignments (LAB-1 through LAB-12) organized in individual folders.

## Structure

```
LAB_WORK/
├── LAB-1/
├── LAB-2/
├── LAB-3/
├── LAB-4/
├── LAB-5/
├── LAB-6/
├── LAB-7/
├── LAB-8/
├── LAB-9/
├── LAB-10/
├── LAB-11/
└── LAB-12/
```

Each folder contains the original content from its corresponding LAB repository.

## How to Use

Navigate to the specific LAB folder you need to access:

```bash
cd LAB-1  # Access LAB-1 content
cd LAB-2  # Access LAB-2 content
# ... and so on
```

---
Created on: $(date)
EOF

git add README.md
git commit -m "Add README for merged LAB repositories"

# Step 5: Push to GitHub
echo -e "${GREEN}[Step 5] Pushing to GitHub...${NC}"
git push -u origin main || git push -u origin master

echo -e "${GREEN}✓ Successfully pushed LAB_WORK repository to GitHub${NC}\n"

# Step 6: Delete original repositories
echo -e "${YELLOW}[Step 6] Deleting original LAB repositories...${NC}"
echo -e "${RED}WARNING: This will permanently delete LAB-1 through LAB-12 repositories!${NC}"
read -p "Are you sure you want to continue? (yes/no): " confirm

if [ "$confirm" = "yes" ]; then
    for i in {1..12}; do
        LAB_NAME="LAB-$i"
        echo -e "${YELLOW}Deleting $LAB_NAME...${NC}"
        
        # Use GitHub API to delete the repository
        # This requires a GitHub Personal Access Token (PAT)
        # Set it as an environment variable: export GITHUB_TOKEN="your_token_here"
        
        if [ -z "$GITHUB_TOKEN" ]; then
            echo -e "${RED}Error: GITHUB_TOKEN environment variable not set!${NC}"
            echo -e "${RED}Please set your GitHub Personal Access Token:${NC}"
            echo -e "${YELLOW}export GITHUB_TOKEN=\"your_token_here\"${NC}"
            echo -e "${RED}Then run this script again.${NC}"
            exit 1
        fi
        
        curl -X DELETE \
            -H "Authorization: token $GITHUB_TOKEN" \
            -H "Accept: application/vnd.github.v3+json" \
            https://api.github.com/repos/$GITHUB_USERNAME/$LAB_NAME
        
        echo -e "${GREEN}✓ $LAB_NAME deleted${NC}\n"
    done
    
    echo -e "${GREEN}=== All LAB repositories have been successfully deleted ===${NC}"
else
    echo -e "${YELLOW}Deletion cancelled. LAB repositories are still available.${NC}"
fi

echo -e "${GREEN}=== Script Completed Successfully ===${NC}"
echo -e "${GREEN}Your new LAB_WORK repository is ready at:${NC}"
echo -e "${YELLOW}https://github.com/$GITHUB_USERNAME/$NEW_REPO_NAME${NC}"
