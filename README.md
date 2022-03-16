# Setup Linux user
A repository containing scripting that sets up a user account on Linux. Run this snippet on the user's account in bash:

```bash
target_path=/tmp/main.sh; curl https://raw.githubusercontent.com/Kleinendorst/setup-linux-user/main/main.sh -o $target_path; chmod u+x $target_path; bash -c $target_path; source ~/.bashrc
```
