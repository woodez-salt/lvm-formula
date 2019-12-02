{% for pillar_key, data in pillar.items() -%}
{% for item in salt['pillar.get']("%s:lvm_storage"|format(pillar_key), {}) -%}
{% set devices = item.get('devices') -%}
{% set vg = item.get('vg') -%}
{% set lv = item.get('lv') -%}
{% set lvsize = item.get('lvsize') -%}
{% set fstype = item.get('fstype') -%}
{% set mountpoint = item.get('mountpoint') -%}

{% set devices = salt['cmd.run']( 'ls -1 ' ~ devices ).split('\n') %}


{% for device in devices %}
{{ device }}:
  lvm.pv_present:
    - require:
      - sls: lvm_storage.init
{% endfor %}

{{ vg }}:
  lvm.vg_present:
    - devices: {{ devices|join(',') }}
    - require:
{% for device in devices %}
      - lvm: {{ device }}
{% endfor %}

{{ lv }}:
  lvm.lv_present:
    - vgname: {{ vg }}
    - size: {{ lvsize }}
    - require:
      - lvm: {{ vg }}

{{ mountpoint }}:
  module.run:
    - name: extfs.mkfs
    - unless: test "$( blkid -s TYPE -o value /dev/mapper/{{ vg }}-{{ lv }} )" = "{{ fstype }}"
    - device: /dev/mapper/{{ vg }}-{{ lv }}
    - fs_type: {{ fstype }}
  mount.mounted:
    - device: /dev/mapper/{{ vg }}-{{ lv }}
    - fstype: {{ fstype }}
    - mkmnt: True
    - opts:
      - defaults
    - require:
      - lvm: {{ lv }}

{% endfor %}
{% endfor %}
