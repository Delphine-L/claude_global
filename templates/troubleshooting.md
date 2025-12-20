# SKILL-NAME Troubleshooting Guide

Comprehensive troubleshooting and debugging guide for common issues.

---

## Quick Diagnostic Checklist

Before diving into specific issues, check these common causes:

- [ ] Required dependencies installed and correct versions
- [ ] Configuration file syntax is valid
- [ ] File paths are correct and accessible
- [ ] Sufficient disk space and memory
- [ ] Proper permissions on files and directories
- [ ] Environment variables set correctly

---

## Common Errors and Solutions

### Error 1: "Command not found"

**Error message:**
```
bash: command: command not found
```

**Cause:** Package not installed or not in PATH

**Solution:**
```bash
# Check if installed
which command

# If not installed (conda example)
conda install -c bioconda package-name

# Or with pip
pip install package-name

# Verify installation
command --version
```

**Alternative causes:**
- Wrong conda environment activated
- Installation in non-standard location
- Path not configured

---

### Error 2: "Permission denied"

**Error message:**
```
Error: Permission denied: /path/to/file
```

**Cause:** Insufficient permissions

**Solution:**
```bash
# Check current permissions
ls -la /path/to/file

# Fix file permissions
chmod 644 /path/to/file

# Fix directory permissions
chmod 755 /path/to/directory

# Check ownership
ls -la /path/to/file

# Change ownership if needed
chown $USER:$USER /path/to/file
```

---

### Error 3: "File not found"

**Error message:**
```
Error: No such file or directory: /path/to/file
```

**Cause:** Incorrect path or file doesn't exist

**Diagnostic steps:**
```bash
# Check if file exists
ls -la /path/to/file

# Check current directory
pwd

# Find file
find . -name "filename"

# Check for typos in path
ls -la /path/to/
```

**Solution:**
- Verify file path is correct
- Use absolute paths instead of relative
- Check for case sensitivity (Linux/macOS)
- Ensure file was created by previous step

---

### Error 4: "Out of memory"

**Error message:**
```
Error: Cannot allocate memory
MemoryError: Unable to allocate X GB
```

**Cause:** Insufficient RAM for operation

**Diagnostic:**
```bash
# Check available memory
free -h

# Check process memory usage
top -o %MEM

# Check system memory
cat /proc/meminfo  # Linux
vm_stat  # macOS
```

**Solutions:**

1. **Reduce memory usage:**
   ```bash
   # Process in chunks
   command --chunk-size 1000 --input large_file

   # Limit threads
   command --threads 2 --input file
   ```

2. **Increase available memory:**
   ```bash
   # Clear cache (Linux)
   sudo sync; sudo sh -c 'echo 3 > /proc/sys/vm/drop_caches'

   # Close other applications
   # Increase swap space (if applicable)
   ```

3. **Use streaming/iterator approach:**
   ```bash
   # Process line by line instead of loading entire file
   command --stream --input huge_file
   ```

---

### Error 5: "Disk space full"

**Error message:**
```
Error: No space left on device
```

**Diagnostic:**
```bash
# Check disk usage
df -h

# Find large files
du -sh * | sort -rh | head -20

# Check specific directory
du -sh /path/to/directory
```

**Solutions:**
```bash
# Clean temporary files
rm -rf /tmp/*
rm -rf ~/.cache/*

# Clean up old logs
find /var/log -name "*.log" -mtime +30 -delete

# Specify different temp directory with more space
command --temp-dir /mnt/large-disk/tmp
```

---

### Error 6: "Connection timeout" or "Network error"

**Error message:**
```
Error: Connection timed out
Error: Unable to download file from URL
```

**Diagnostic:**
```bash
# Test connectivity
ping hostname

# Check URL accessibility
curl -I https://url.com/file

# Test with wget
wget --spider https://url.com/file

# Check proxy settings
echo $HTTP_PROXY
echo $HTTPS_PROXY
```

**Solutions:**

1. **Increase timeout:**
   ```bash
   command --timeout 300 --url https://...
   ```

2. **Use mirror or alternative source:**
   ```bash
   command --mirror alternative-url
   ```

3. **Configure proxy:**
   ```bash
   export HTTP_PROXY=http://proxy:port
   export HTTPS_PROXY=http://proxy:port
   command --url https://...
   ```

---

## Debugging Workflows

### Step 1: Enable Verbose/Debug Mode

```bash
# Enable verbose output
command --verbose

# Enable debug mode
command --debug

# Increase log level
command --log-level DEBUG

# Save debug output
command --debug > debug_output.log 2>&1
```

### Step 2: Check Logs

**Log locations:**
- Application logs: `/var/log/application.log`
- User logs: `~/.local/share/application/logs/`
- Current directory: `./logs/`

**Reading logs efficiently:**
```bash
# Last 50 lines
tail -50 application.log

# Follow logs in real-time
tail -f application.log

# Search for errors
grep -i "error\|fail\|exception" application.log

# Show context around errors
grep -C 5 "ERROR" application.log
```

### Step 3: Validate Input Files

```bash
# Check file format
file input.txt

# Check line endings (Windows vs Unix)
dos2unix input.txt  # Convert if needed

# Validate file integrity
md5sum input.txt
sha256sum input.txt

# Check for special characters
cat -A input.txt | head -20

# Validate JSON
jq . input.json

# Validate YAML
yamllint input.yaml
```

### Step 4: Test with Minimal Example

**Create minimal test case:**
```bash
# Create small test file
head -10 large_input.txt > test_input.txt

# Run with minimal options
command --input test_input.txt --output test_output.txt

# If works, gradually increase complexity
```

---

## Platform-Specific Issues

### macOS Specific

**Issue: "dyld: Library not loaded"**

**Solution:**
```bash
# Check library dependencies
otool -L /path/to/binary

# Install missing libraries via Homebrew
brew install library-name

# Update library paths
export DYLD_LIBRARY_PATH=/usr/local/lib:$DYLD_LIBRARY_PATH
```

**Issue: "Operation not permitted" (SIP)**

**Solution:**
- Don't disable SIP
- Install in user directory instead of system directories
- Use Homebrew for system-wide tools

### Linux Specific

**Issue: "error while loading shared libraries"**

**Solution:**
```bash
# Check library
ldd /path/to/binary

# Update library cache
sudo ldconfig

# Add library path
export LD_LIBRARY_PATH=/usr/local/lib:$LD_LIBRARY_PATH
```

### Windows Specific

**Issue: "DLL not found"**

**Solution:**
- Install Visual C++ Redistributables
- Add DLL location to PATH
- Copy DLL to executable directory

---

## Performance Issues

### Symptom: Slow Performance

**Diagnostic:**
```bash
# Profile execution time
time command --input file

# Monitor resource usage
# Linux:
top
htop
iotop

# macOS:
top -o cpu
Activity Monitor (GUI)
```

**Solutions:**

1. **Enable parallelization:**
   ```bash
   command --threads $(nproc)
   ```

2. **Use faster disk:**
   ```bash
   # Move to SSD
   command --temp-dir /mnt/ssd/tmp
   ```

3. **Optimize I/O:**
   ```bash
   # Increase buffer size
   command --buffer-size 8192
   ```

4. **Disable unnecessary features:**
   ```bash
   # Disable verbose output
   command --quiet

   # Skip validation if trusted input
   command --no-validate
   ```

---

## Getting Help

### Collect Information for Bug Report

```bash
# Version information
command --version

# System information
uname -a  # Linux/macOS
systeminfo  # Windows

# Environment
echo $PATH
conda env export  # If using conda

# Run with debug and save output
command --debug --input file > output.log 2>&1
```

### Where to Get Help

- **Documentation:** https://docs.example.com
- **Issue tracker:** https://github.com/org/repo/issues
- **Community forum:** https://forum.example.com
- **Chat:** https://chat.example.com

### Bug Report Template

```markdown
**Description:**
Brief description of the issue

**To Reproduce:**
1. Step 1
2. Step 2
3. Step 3

**Expected behavior:**
What should happen

**Actual behavior:**
What actually happens

**Environment:**
- OS: [e.g. Ubuntu 22.04]
- Version: [e.g. 1.2.3]
- Installation method: [conda/pip/source]

**Additional context:**
- Log output
- Configuration files
- Screenshots if applicable
```

---

## FAQ

### Q: Why is the command slow on large files?

**A:** Processing large files requires significant memory and I/O. Solutions:
- Enable streaming mode: `--stream`
- Process in chunks: `--chunk-size 1000`
- Use faster disk (SSD vs HDD)
- Increase buffer size: `--buffer-size 8192`

### Q: Can I run multiple instances in parallel?

**A:** Yes, but considerations:
- Each instance needs separate output directory
- Memory: ensure sufficient RAM (instance_count × memory_per_instance)
- I/O: parallel writes may slow down on HDD
- Use different temp directories: `--temp-dir`

### Q: How do I resume interrupted processing?

**A:** Depends on implementation:
```bash
# If supports checkpointing
command --resume --checkpoint-file state.ckpt

# Otherwise, identify completed items and skip
command --input remaining_files.txt
```

---

## Still Having Issues?

If none of these solutions work:

1. **Search existing issues:** Check if someone else reported it
2. **Create minimal reproducible example:** Simplest case that shows the problem
3. **Collect debug information:** Version, OS, logs, config
4. **File an issue:** Use the bug report template above
5. **Ask in community:** Forum or chat for quick help
