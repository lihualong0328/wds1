@*************************************************************************
@ File��head.S
@ ���ܣ�����SDRAM�����ڶ����ִ��븴�Ƶ�SDRAM������ҳ��������MMU��
@       Ȼ������SDRAM����ִ��
@*************************************************************************       

.text
.global _start
_start:
    ldr sp, =4096                       @ ����ջָ��(sram���)�����¶���C����������ǰ��Ҫ���ջ
    bl  disable_watch_dog               @ �ر�WATCHDOG������CPU�᲻������
    bl  memsetup                        @ ���ô洢��������ʹ��SDRAM
    bl  copy_2th_to_sdram               @ ���ڶ����ִ��븴�Ƶ�SDRAM
    bl  create_page_table               @ ����ҳ��
    bl  mmu_init                        @ ����MMU
    ldr sp, =0xB4000000                 @ ����ջָ��(���ϲ���pcָ��sram)��ָ��SDRAM����(��ʼʹ��va)
    ldr pc, =0xB0004000                 @ ����SDRAM�м���ִ�еڶ����ִ���; �൱�� ldr pc, =main; ��Ϊleds.o��ֻ��main(). ������Ϊ�˷���ֱ�۵Ŀ���va ��������
halt_loop:
    b   halt_loop
