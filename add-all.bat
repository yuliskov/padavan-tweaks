@echo off

cd /d "%~dp0"

REM REM presence of scp indicates that environment is initialized
REM WHERE scp >nul 2>nul
REM IF %ERRORLEVEL% EQU 0 goto SKIP

REM setenv %~n0
REM exit

REM :SKIP

REM REM REM REM REM REM REM REM REM REM REM REM REM REM REM REM REM REM

REM How to enable network access to VirtualBox:
REM VBoxManage modifyvm mi-nano --natpf1 "ssh,tcp,,3022,,22"
REM VBoxManage showvminfo mi-nano | grep 'Rule'
REM ssh -p 3022 foreman@127.0.0.1
REM sudo apt-get install openssh-server

REM 'add-common-files' content: files that are shared amont multiple packages. controls inclusion for modules and services.
REM 'add-grey-theme' content: fixes for grey theme. icludes button style fix, link style fix, centering loading popup

echo.
echo "Uploading patches on to the server"
echo.

echo.
echo "Add Common Files"
echo "Add Paragon NTFS Driver"
echo "Add Replace ASUS with Xiaomi"
echo "Add Tinyproxy proxy server"
echo.

REM set REPO=xrmwrt
set REPO=rt-n56u
set SCP_PORT=-P 3022
set SSH_PORT=-p 3022
set IP_ADDR=127.0.0.1
set SSH_LOGIN=foreman
set TOR_SCRIPT_PATH=~/last_patch.sh
set TOR_SCRIPT_URL=http://www.qwe-qwe.me/patch/last_patch.sh
set REPO_PATH=~/rt-n56u
REM set IP_ADDR=192.168.121.129
REM set SSH_LOGIN=user

REM cleanup, patch in reverse order
echo CLEANUP: remove patches in reverse order
ssh %SSH_PORT% %SSH_LOGIN%@%IP_ADDR% "cd %REPO_PATH%/trunk; ls *.patch | sort -r | xargs cat | patch -r - -N -R -p0; rm -r *.patch *.patch.* user/samba36 user/privoxy user/tor user/kms-server user/tinyproxy libs/libpcre user/www/n56u_ribbon_fixed/*-theme"
REM add custom files
echo COPYING: add custom files
REM scp %SCP_PORT% -r add-grey-theme-2/. add-common-files/. add-xiaomi-brand/. add-tinyproxy/. add-privoxy/. add-curl/. add-libs/. add-samba36/. add-paragon-ntfs/. add-ntfs-3g/. add-kms-server/. %SSH_LOGIN%@%IP_ADDR%:%REPO_PATH%/trunk/
scp %SCP_PORT% -r add-*/. %SSH_LOGIN%@%IP_ADDR%:%REPO_PATH%/trunk/
REM apply webui patch
echo PATCH: apply custom patches
ssh %SSH_PORT% %SSH_LOGIN%@%IP_ADDR% "cd %REPO_PATH%/trunk; cat *.patch | patch -r - -N -p0; find . -name *.rej -o -name *.orig | xargs -r rm"

REM ssh %SSH_PORT% %SSH_LOGIN%@%IP_ADDR% "cd %REPO_PATH%/trunk; patch -r - -N -p0 < mi_mini_main.patch"
REM ssh %SSH_PORT% %SSH_LOGIN%@%IP_ADDR% rm ~/%REPO%/trunk/user/rc/common_ex.o; rm ~/%REPO%/trunk/stage/.installed_*



REM REM uninstall tor script
REM ssh %SSH_PORT% %SSH_LOGIN%@%IP_ADDR% "cd %REPO_PATH%/trunk; patch -r - -N -R -p0 < mi-mini-tor.patch; rm -r libs/libpcre libs/libsodium user/privoxy user/tor user/dnscrypt-proxy"

REM REM download script
REM REM extract archive from script
REM REM patch webui files
REM ssh %SSH_PORT% %SSH_LOGIN%@%IP_ADDR% "cd %REPO_PATH%/trunk; wget %TOR_SCRIPT_URL% -O %TOR_SCRIPT_PATH%; sed '1,/^---- .*/d' %TOR_SCRIPT_PATH% | base64 -d | tar xvzf - || echo Archive corrupted; mv rt-n56u-tor+privoxy+dnscrypt_*.patch mi-mini-tor.patch; patch -r - -N -p0 < mi-mini-tor.patch || echo Patch corrupted or old patch"



REM don't reverse, don't save rejects, fuzz==0
REM apply patch: patch -r - -N -F 0 -p0 < mi-mini-tor.patch
REM remove patch: patch -r - -N -F 0 -R -p0 < mi-mini-tor.patch

REM ssh %SSH_PORT% %SSH_LOGIN%@%IP_ADDR% rm ~/%REPO%/trunk/user/rc/common_ex.o
REM ssh %SSH_PORT% %SSH_LOGIN%@%IP_ADDR% rm -r ~/%REPO%/trunk/stage

REM ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null "$ROOTWRT"@"$IPWRT" "cd /opt; tar -zcvf /tmp/entware.tar.gz $TARGET_PATHS"

pause
exit
