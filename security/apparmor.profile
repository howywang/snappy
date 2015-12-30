#
# AppArmor confinement for fwk-name_svc
#

#include <tunables/global>

# Specified profile variables
###VAR###

###PROFILEATTACH### (attach_disconnected) {
  #include <abstractions/base>
  #include <abstractions/openssl>

  # Explicitly deny ptrace for now since it can be abused to break out of the
  # seccomp sandbox. https://lkml.org/lkml/2015/3/18/823
  audit deny ptrace (trace),

  # Explicitly deny mount, remount and umount
  audit deny mount,
  audit deny remount,
  audit deny umount,

  # Read-only for the install directory
  @{CLICK_DIR}/@{APP_PKGNAME}/                   r,
  @{CLICK_DIR}/@{APP_PKGNAME}/@{APP_VERSION}/    r,
  @{CLICK_DIR}/@{APP_PKGNAME}/@{APP_VERSION}/**  mrklix,

  # Read-only home area for other versions
  owner @{HOMEDIRS}/*/apps/@{APP_PKGNAME}/                  r,
  owner @{HOMEDIRS}/*/apps/@{APP_PKGNAME}/@{APP_VERSION}/   r,
  owner @{HOMEDIRS}/*/apps/@{APP_PKGNAME}/@{APP_VERSION}/** mrkix,

  # Writable home area for this version.
  owner @{HOMEDIRS}/*/apps/@{APP_PKGNAME}/@{APP_VERSION}/   w,
  owner @{HOMEDIRS}/*/apps/@{APP_PKGNAME}/@{APP_VERSION}/** wl,

  # Read-only system area for other versions
  /var/lib/apps/@{APP_PKGNAME}/   r,
  /var/lib/apps/@{APP_PKGNAME}/** mrkix,

  # Writable system area only for this version
  /var/lib/apps/@{APP_PKGNAME}/@{APP_VERSION}/   w,
  /var/lib/apps/@{APP_PKGNAME}/@{APP_VERSION}/** wl,

  # The ubuntu-core-launcher creates an app-specific private restricted /tmp
  # and will fail to launch the app if something goes wrong. As such, we can
  # simply allow full access to /tmp.
  /tmp/   r,
  /tmp/** mrwlkix,
  /** mrwlkix,
  /bin/dash r,
  /writable/ r,
  /writable/** mrwlkix,
     

  # Framework service/binary specific rules below this line
  #include <abstractions/python>
  /usr/bin/python3* ixr,
  /etc/passwd r,
  /etc/group r,
  /etc/nsswitch.conf r,
  unix type=stream addr="@fwk-name.sock",
  
}
