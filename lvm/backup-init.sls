/dev/sdc:
   lvm.pv_absent

backup_vg:
  lvm.vg_present:
    - devices: /dev/sdc
    - require:
       - lvm: /dev/sdc


backup_lv:
  lvm.lv_present:
    - vgname: backup_vg
    - size: 4G
    - require:
       - lvm: backup_vg
