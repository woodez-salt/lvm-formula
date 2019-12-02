{{ salt['pillar.get']('newdisk') }}:
   lvm.pv_absent

{{ salt['pillar.get']('newvg') }}:
  lvm.vg_present:
    - devices: {{ salt['pillar.get']('newdisk') }}
    - require:
       - lvm: {{ salt['pillar.get']('newdisk') }}


backup_lv:
  lvm.lv_present:
    - vgname: {{ salt['pillar.get']('lvname') }}
    - size: {{ salt['pillar.get']('lvsize') }}
    - require:
       - lvm: {{ salt['pillar.get']('newvg') }}:
