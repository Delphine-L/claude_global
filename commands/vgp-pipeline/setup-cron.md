---
description: Set up cron job for automated workflow monitoring
---

You are helping set up a cron job to automatically monitor and progress VGP workflows.

## Your Task

1. **Understand the environment**:
   - Ask user about their environment (local, HPC, SLURM)
   - Ask about preferred polling interval (hourly recommended)
   - Ask if they want automatic retry of failed workflows
   - Determine log file location preference

2. **Verify manual command works**:
   ```bash
   cd /path/to/VGP-planemo-scripts
   vgp-run-all --resume -p profile.yaml -m ./metadata/ --quiet
   ```
   Confirm this runs successfully before proceeding.

3. **Create wrapper script if needed** (especially for HPC):
   ```bash
   #!/bin/bash
   # ~/vgp_cron.sh
   source ~/.bashrc
   cd /path/to/VGP-planemo-scripts || exit 1
   vgp-run-all --resume -p profile.yaml -m ./metadata/ --quiet 2>&1
   ```
   Make it executable: `chmod +x ~/vgp_cron.sh`

4. **Generate cron entry based on preferences**:

   **Basic hourly (recommended):**
   ```cron
   0 * * * * cd /path/to/VGP-planemo-scripts && vgp-run-all --resume -p profile.yaml -m ./metadata/ --quiet >> cron.log 2>&1
   ```

   **Every 30 minutes:**
   ```cron
   0,30 * * * * cd /path/to/VGP-planemo-scripts && vgp-run-all --resume -p profile.yaml -m ./metadata/ --quiet >> cron.log 2>&1
   ```

   **With automatic retry:**
   ```cron
   0 * * * * cd /path/to/VGP-planemo-scripts && vgp-run-all --resume --retry-failed -p profile.yaml -m ./metadata/ --quiet >> cron.log 2>&1
   ```

   **HPC with wrapper script:**
   ```cron
   0 * * * * /home/user/vgp_cron.sh >> /home/user/vgp_cron.log 2>&1
   ```

5. **Provide setup instructions**:
   ```bash
   # Edit crontab
   crontab -e

   # Add the cron entry (paste the line from above)

   # Verify it's added
   crontab -l
   ```

6. **Show monitoring commands**:
   ```bash
   # Watch logs in real-time
   tail -f cron.log

   # Check recent activity
   tail -50 cron.log

   # Search for errors
   grep -i "error\|fail" cron.log
   ```

7. **Provide troubleshooting tips**:
   - Environment variables: Use `source ~/.bashrc`
   - Working directory: Always include `cd /path`
   - Absolute paths: Never use relative paths in cron
   - Test manually first: Run exact command before adding to cron
   - Log redirection: Always use `>> log.txt 2>&1`

## Output Format

Provide:
1. ✅ Prerequisites checklist
2. 📝 Recommended cron entry (copy-paste ready)
3. 🔧 Setup commands
4. 👀 Monitoring commands
5. 🐛 Troubleshooting tips
