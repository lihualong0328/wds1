
#define S3C2440_MPLL_200MHZ     ((0x5c<<12)|(0x01<<4)|(0x02))
#define MEM_CTL_BASE    0x48000000

.text							 	/* ����� */
.global _start						/* _start��ȫ�ֱ�� */
_start:
/* 1. �ؿ��Ź����ο� nand ��� */
/* ��=��ldrָ����α���ָ�����ʱ�����������תΪ����ָ�������� */
/* ��� 0x53000000 �ܱ�ʾΪ������������ʱֱ��תΪmov r0, 0x53000000������� 0x53000000 �����ڴ棬�ٶ��ڴ�(����ָ��) */
	ldr r0, =0x53000000
	mov r1, #0
	str r1, [r0]	/* ��r1ֵ�洢��r0��ַ */

/* 2. ����ʱ�ӣ��ο� lcd ��� */
	ldr r0, =0x4c000014
	mov r1, #0x03;            /* ldr r1, =0x03; ��Ϊ0x03��, ���Կ�ֱ����mov */
	str r1, [r0]

	/* ���HDIVN��0��CPU������ģʽӦ�ôӡ�fast bus mode����Ϊ��asynchronous bus mode�� */
	/* 2440�ֲ�Ҫ�� : ��cpuʱ��FCLK!=HCLK(�ڴ�ʱ��)ʱ����Ҫ��Ϊ"asynchronous bus mode" */
	mrc	p15, 0, r1, c1, c0, 0		/* �������ƼĴ��� */ 
	orr	r1, r1, #0xc0000000			/* ����Ϊ��asynchronous bus mode�� */
	mcr	p15, 0, r1, c1, c0, 0		/* д����ƼĴ��� */

	/* MPLLCON = S3C2440_MPLL_200MHZ */
	ldr r0, =0x4c000004
	ldr r1, =S3C2440_MPLL_200MHZ	/* S3C2440_MPLL_200MHZ ���ӣ�����û������������ʾ��������α��� */
	str r1, [r0]

/* 3. ��ʼ��SDRAM */
	ldr r0, =MEM_CTL_BASE	/* α��� */
	adr r1, sdram_config    /* α��࣬sdram_config��ŵĵ�ǰ��ַ�������ӵ�ַ�� */
	add r3, r0, #(13*4)
1:
	ldr r2, [r1], #4		/* ��ȡr1��ַ��ֵ�浽r2����r1+4 */
	str r2, [r0], #4		/* ��r2ֵ�浽r0��ַ����r0+4 */
	cmp r0, r3
	bne 1b					/* 1b,1back������������ж��1��ţ���ʱ����1f & 1b���� */

/* 4. �ض�λ : �� bootloader ��������� flash ���Ƶ��������ӵ�ַȥ */
	ldr sp, =0x34000000	/* sdram ����ַ=0x30000000��64M=4000000����ָ������ڴ棬ջ������������ */

	bl nand_init

	/* Ϊ copy_code_to_sdram(r0, r1, r2) ׼���β� */
	//ldr r1, =_start	//ȡ_start�ĵ�ַ��λ�����
	//ldr r1, _start	//ȡ_start����ֵ��λ���޹�
	mov r0, #0				/* norʱ��0��ַ����nor����ֱ�Ӳ�����nandʱ��0��ַ��Ƭ��ram���������õ���nand_read()��0��ַ��nand��0��ַ */
	ldr r1, =_start			/* dest �����ӵ�ַ(_start ��ŵ�ַ==���ӵ�ַ) */
	ldr r2, =__bss_start	
	sub r2, r2, r1			/* len �� uboot.bin ��С�����е� */
	
	bl copy_code_to_sdram	/* �ض�λ */
	bl clear_bss
	
/* 5. ִ��main */
	/* bl main */	/* bl�������ת�������0��ַ��ʼִ�У������ת�������� sdram��bl�Ǹ��ݵ�ǰָ���ַ���ҵ� main �� offset ֵ���� */
	ldr lr, =halt	/* ���� main ���ص�ַ */
	ldr pc, =main	/* ��ת�� sdram */
halt:				/* main �����ڴ���ѭ���������ܷ� */
	b halt

/* ���� : start.S�����ָ������������ݲ��� */
sdram_config:
	.long 0x22011110	 //BWSCON
	.long 0x00000700	 //BANKCON0
	.long 0x00000700	 //BANKCON1
	.long 0x00000700	 //BANKCON2
	.long 0x00000700	 //BANKCON3  
	.long 0x00000700	 //BANKCON4
	.long 0x00000700	 //BANKCON5
	.long 0x00018005	 //BANKCON6
	.long 0x00018005	 //BANKCON7
	.long 0x008C04F4	 //REFRESH
	.long 0x000000B1	 //BANKSIZE
	.long 0x00000030	 //MRSRB6
	.long 0x00000030	 //MRSRB7
