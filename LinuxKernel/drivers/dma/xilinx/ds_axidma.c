/*
 * Xilinx AXI DMA Driver
 *
 * Authors:
 *    Fabrizio Spada - fabrizio.spada@mail.polimi.it
 *    Gianluca Durelli - durelli@elet.polimi.it
 *    Politecnico di Milano
 *
 * This is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2 of the License, or
 * (at your option) any later version.
 */
#include <linux/delay.h>
#include <linux/module.h>
#include <linux/version.h>
#include <linux/kernel.h>
#include <linux/types.h>
#include <linux/kdev_t.h>
#include <linux/fs.h>
#include <linux/list.h>
#include <linux/device.h>
#include <linux/cdev.h>
#include <linux/dma-mapping.h>
#include <linux/pm_runtime.h>
#include <linux/slab.h>
#include <linux/of.h>
#include <linux/of_platform.h>
#include <linux/of_address.h>
#include <linux/highmem.h>
#include <linux/mm.h>
#include <asm/io.h>
#include <linux/pagemap.h>
#include <linux/interrupt.h>
#include <linux/limits.h>

#define MM2S_DMA_CONTROL_REG		0x00
#define MM2S_DMA_STATUS_REG			0x04
#define MM2S_SOURCE_ADDRESS_REG		0x18
#define MM2S_TRANSFER_LENGTH		0x28

#define S2MM_DMA_CONTROL_REG		0x30
#define S2MM_DMA_STATUS_REG			0x34
#define S2MM_DESTINATION_ADDRESS	0x48
#define S2MM_BUFFER_LENGTH			0x58

#define DRIVER_NAME					"ds_axidma_pdrv"
#define MODULE_NAME 				"ds_axidma"

#define DMA_LENGTH					(32*1024)

int flag = 0;

static struct class *cl;	// Global variable for the device class

struct ds_axidma_device
{
	phys_addr_t 		bus_addr;
	unsigned long 		bus_size;
	char 				*virt_bus_addr;		// Assigned Offset Address to IP in Vivado
	dev_t 				dev_num;
	const char 			*dev_name;
	struct cdev 		c_dev;
	char 				*ds_axidma_addr;
	dma_addr_t 			ds_axidma_handle;
	int					irq;

	struct list_head 	dev_list;
};
LIST_HEAD( full_dev_list );

extern unsigned long volatile jiffies;

char 				*ds_axidma_addr2;
dma_addr_t 			ds_axidma_handle2;

static struct ds_axidma_device *get_elem_from_list_by_inode(struct inode *i)
{
	struct list_head *pos;
	struct ds_axidma_device *obj_dev = NULL;

	list_for_each( pos, &full_dev_list )
	{
		struct ds_axidma_device *tmp;
    	tmp = list_entry( pos, struct ds_axidma_device, dev_list );
    	if (tmp->dev_num == i->i_rdev)
    	{
    		obj_dev = tmp;
    		break;
    	}
  	}
  	return obj_dev;
}
// static void dmaHalt(void){
// 	unsigned long mm2s_halt = ioread32(virt_bus_addr + MM2S_DMA_STATUS_REG) & 0x1;
// 	unsigned long s2mm_halt = ioread32(virt_bus_addr + S2MM_DMA_STATUS_REG) & 0x1;
// 	int count = 0;
// 	printk(KERN_INFO "Halting...\n");
// 	iowrite32(0, virt_bus_addr + S2MM_DMA_CONTROL_REG);
// 	iowrite32(0, virt_bus_addr + MM2S_DMA_CONTROL_REG);
// 	while( !mm2s_halt || !s2mm_halt){
// 		// mm2s_halt = ioread32(virt_bus_addr + MM2S_DMA_STATUS_REG) & 0x1;
// 		mm2s_halt = virt_bus_addr[MM2S_DMA_STATUS_REG] & 0x1;
// 		//s2mm_halt = ioread32(virt_bus_addr + S2MM_DMA_STATUS_REG) & 0x1;
// 		s2mm_halt = virt_bus_addr[S2MM_DMA_STATUS_REG] & 0x1;
// 		count++;
// 		if (count>100 )
// 		{
// 			break;
// 		}
// 	}

// 	printk(KERN_INFO "DMA Halted!\n");
// }

static int my_strcmp(const char *str1, const char *str2)
{
  int i;
  i = 0;
  while (str1[i] || str2[i])
    {
      if (str1[i] != str2[i])
        return (str1[i] - str2[i]);
      i++;
    }
  return (0);
}

// static int dmaSynchMM2S(struct ds_axidma_device *obj_dev){
// 	//	sleep(6);
// 	//	return;
//
// 	unsigned int mm2s_status = ioread32(obj_dev->virt_bus_addr + MM2S_DMA_STATUS_REG);
// 	while(!(mm2s_status & 1<<12) || !(mm2s_status & 1<<1) ){
// 		mm2s_status = ioread32(obj_dev->virt_bus_addr + MM2S_DMA_STATUS_REG);
//
// 	}
// 	return 0;
// }

static int dmaSynchS2MM(struct ds_axidma_device *obj_dev){
	unsigned int s2mm_status = ioread32(obj_dev->virt_bus_addr + S2MM_DMA_STATUS_REG);
	while(!(s2mm_status & 1<<12) || !(s2mm_status & 1<<1)){
		s2mm_status = ioread32(obj_dev->virt_bus_addr + S2MM_DMA_STATUS_REG);
	}
	return 0;
}

static int ds_axidma_open(struct inode *i, struct file *f)
{
	/* printk(KERN_INFO "<%s> file: open()\n", MODULE_NAME); */
	struct ds_axidma_device *obj_dev = get_elem_from_list_by_inode(i);
	if (check_mem_region(obj_dev->bus_addr, obj_dev->bus_size))
	{
		return -1;
	}
	request_mem_region(obj_dev->bus_addr, obj_dev->bus_size, MODULE_NAME);
	obj_dev->virt_bus_addr = (char *) ioremap_nocache(obj_dev->bus_addr, obj_dev->bus_size);

	iowrite32(4097, obj_dev->virt_bus_addr + S2MM_DMA_CONTROL_REG);
	iowrite32(4096, obj_dev->virt_bus_addr + S2MM_DMA_STATUS_REG);
	iowrite32(1, obj_dev->virt_bus_addr + MM2S_DMA_CONTROL_REG);
	iowrite32(obj_dev->ds_axidma_handle, obj_dev->virt_bus_addr + MM2S_SOURCE_ADDRESS_REG);
	iowrite32(obj_dev->ds_axidma_handle, obj_dev->virt_bus_addr + S2MM_DESTINATION_ADDRESS);

	return 0;
}

static int ds_axidma_close(struct inode *i, struct file *f)
{
	/* printk(KERN_INFO "<%s> file: close()\n", MODULE_NAME); */
	struct ds_axidma_device *obj_dev = get_elem_from_list_by_inode(i);
	iounmap(obj_dev->virt_bus_addr);
	release_mem_region(obj_dev->bus_addr, obj_dev->bus_size);
	return 0;
}

static ssize_t ds_axidma_read(struct file *f, char __user * buf, size_t len, loff_t * off)
{
	// /* printk(KERN_INFO "<%s> file: read()\n", MODULE_NAME); */
	// struct ds_axidma_device *obj_dev;
	// if (len >= DMA_LENGTH)
	// {
	// 	return 0;
	// }
	// obj_dev = get_elem_from_list_by_inode(f->f_inode);
	// iowrite32(1, obj_dev->virt_bus_addr + S2MM_DMA_CONTROL_REG);
	// iowrite32(obj_dev->ds_axidma_handle, obj_dev->virt_bus_addr + S2MM_DESTINATION_ADDRESS);
	// iowrite32(len, obj_dev->virt_bus_addr + S2MM_BUFFER_LENGTH);
	// dmaSynchS2MM(obj_dev);
	// memcpy(buf, obj_dev->ds_axidma_addr, len);
	// return len;

	printk(KERN_INFO "This \"read\" method is not implemented!\n");

	/* enable user-mode access to the performance counter*/
	asm ("MCR p15, 0, %0, C9, C14, 0\n\t" :: "r"(1));
	/* disable counter overflow interrupts (just in case)*/
	asm ("MCR p15, 0, %0, C9, C14, 2\n\t" :: "r"(0x8000000f));

	return 0;
}

static inline unsigned int get_cyclecount (void)
{
	unsigned int value;
	// Read CCNT Register
	asm volatile ("MRC p15, 0, %0, c9, c13, 0\t\n": "=r"(value));
	return value;
}

static inline void init_perfcounters (int32_t do_reset, int32_t enable_divider)
{
  // in general enable all counters (including cycle counter)
  int32_t value = 1;

  // peform reset:
  if (do_reset)
  {
    value |= 2;     // reset all counters to zero.
    value |= 4;     // reset cycle counter to zero.
  }

  if (enable_divider)
    value |= 8;     // enable "by 64" divider for CCNT.

  value |= 16;

  // program the performance-counter control-register:
  asm volatile ("MCR p15, 0, %0, c9, c12, 0\t\n" :: "r"(value));

  // enable all counters:
  asm volatile ("MCR p15, 0, %0, c9, c12, 1\t\n" :: "r"(0x8000000f));

  // clear overflows:
  asm volatile ("MCR p15, 0, %0, c9, c12, 3\t\n" :: "r"(0x8000000f));
}

static ssize_t ds_axidma_write(struct file *f, const char __user * buf,  size_t len, loff_t * off)
{

	struct ds_axidma_device *obj_dev;
	unsigned int counter = 0;


			unsigned int overhead, i = 0;
			unsigned int a, b, c, d, e, g;
			unsigned int m1_avg, wr_avg, wt_avg, m2_avg;

			// measure the counting overhead:
			init_perfcounters (1, 0);

			overhead = get_cyclecount();
			overhead = get_cyclecount() - overhead;

			m1_avg 	= 0;
			wr_avg 	= 0;
			wt_avg 	= 0;
			m2_avg 	= 0;

			// Execute code for 512 times, and average profilinf results
			for(i=0; i<512; i++)
			{

				// Reset counters at each loop
				init_perfcounters (1, 0);

				a = get_cyclecount();

	// get the device of the driver file f 
	obj_dev = get_elem_from_list_by_inode(f->f_inode);

	// set interrupt flag, which will be reset by interrupt handler function
	flag = 1;
				// Reset interrupt flag, only necessary if interrupt is not used
				iowrite32(4096, obj_dev->virt_bus_addr + S2MM_DMA_STATUS_REG);
				wmb();

				b = get_cyclecount();

	// copy input buffer to coherent memory space
	memcpy(obj_dev->ds_axidma_addr, buf, len);

				c = get_cyclecount();

	// Write length of data trasnfer to initiate transfer
	iowrite32(len, obj_dev->virt_bus_addr + MM2S_TRANSFER_LENGTH);


				d = get_cyclecount();

	// poll for DMA transfer comlete
	dmaSynchS2MM(obj_dev);


	// // Wait for interrupt flag
	// // When interrupt occur, flag will be zeroed the handler function
	// // If counter exceeds UINT_MAX while waiting, don't wait anymore
	// while(flag > 0){
	// 	counter++;
	//
	// 	if(counter == UINT_MAX){
	// 		printk(KERN_INFO "HW Interrupt didn't happen.\n");
	//
	// 		// I know I should return 0 here, but when I do,
	// 		// counter reaches to max value before interrupt occurs.
	// 		// Might it be some sort of good compiler optimization GCC does?
	//
	// 		//return 0;
	// 	}
	// }

				e = get_cyclecount();

	// copy received buffer at ciherent memory space back to input buffer
	memcpy((char __user*)buf, obj_dev->ds_axidma_addr, len);


				g = get_cyclecount();

				// acculmulate counters
				m1_avg 	+= c - b - overhead;
				wr_avg 	+= d - c - overhead;
				wt_avg 	+= e - d - overhead;
				m2_avg 	+= g - e - overhead;
			}

			// take average of counters
			m1_avg /= 512;
			wr_avg /= 512;
			wt_avg /= 512;
			m2_avg /= 512;

			// show counters
			printk ("memcpy() %d cycles\n", m1_avg);
			printk ("iowrite32() %d cycles\n", wr_avg);
			printk ("waiting %d cycles\n", wt_avg);
			printk ("memcpy() %d cycles\n", m2_avg);
			printk ("total %d cycles\n", m1_avg + wr_avg + wt_avg + m2_avg);
			printk ("total %d cycles\n", g-a);



	// printk(KERN_INFO "MM2S_DMA_STATUS_REG: %X\n", ioread32(obj_dev->virt_bus_addr + MM2S_DMA_STATUS_REG));
	// printk(KERN_INFO "MM2S_DMA_CONTROL_REG: %X\n", ioread32(obj_dev->virt_bus_addr + MM2S_DMA_CONTROL_REG));
	// printk(KERN_INFO "S2MM_DMA_STATUS_REG: %X\n", ioread32(obj_dev->virt_bus_addr + S2MM_DMA_STATUS_REG));
	// printk(KERN_INFO "S2MM_DMA_CONTROL_REG: %X\n", ioread32(obj_dev->virt_bus_addr + S2MM_DMA_CONTROL_REG));

	// printk(KERN_INFO "%X\n", bus_addr);
	// printk(KERN_INFO "%lu\n", bus_size);

	return len;
}

static struct file_operations fops = {
	.owner = THIS_MODULE,
	.open = ds_axidma_open,
	.release = ds_axidma_close,
	.read = ds_axidma_read,
	.write = ds_axidma_write,
	/*.mmap = ds_axidma_mmap,*/
	/* .unlocked_ioctl = ds_axidma_ioctl, */
};

static irqreturn_t timer_irq_handler(int irq, void *dev_id)
{
	//printk(KERN_INFO "IRQ_HANDLED\n");

	flag = 0;

	return IRQ_HANDLED;
}

static int ds_axidma_pdrv_probe(struct platform_device *pdev)
{
	int returnVal;

	/* device constructor */
	struct ds_axidma_device *obj_dev = (struct ds_axidma_device *)
            kmalloc( sizeof(struct ds_axidma_device), GFP_KERNEL );
    obj_dev->bus_addr = pdev->resource[0].start;
    obj_dev->bus_size = pdev->resource[0].end - pdev->resource[0].start + 1;
	obj_dev->dev_name = pdev->name + 9;

	printk(KERN_INFO "<%s> init: registered\n", obj_dev->dev_name);
	if (alloc_chrdev_region(&(obj_dev->dev_num), 0, 1, obj_dev->dev_name) < 0) {
		return -1;
	}
	if (cl == NULL && (cl = class_create(THIS_MODULE, "chardrv")) == NULL) {
		unregister_chrdev_region(obj_dev->dev_num, 1);
		return -1;
	}
	if (device_create(cl, NULL, obj_dev->dev_num, NULL, obj_dev->dev_name) == NULL) {
		class_destroy(cl);
		unregister_chrdev_region(obj_dev->dev_num, 1);
		return -1;
	}
	cdev_init(&(obj_dev->c_dev), &fops);
	if (cdev_add(&(obj_dev->c_dev), obj_dev->dev_num, 1) == -1) {
		device_destroy(cl, obj_dev->dev_num);
		class_destroy(cl);
		unregister_chrdev_region(obj_dev->dev_num, 1);
		return -1;
	}

	printk(KERN_INFO "DMA_LENGTH = %u \n", DMA_LENGTH);

	/* Register the interrupt */
	obj_dev->irq = platform_get_irq(pdev, 0);
	if (obj_dev->irq >= 0) {
		returnVal = request_irq(obj_dev->irq, timer_irq_handler, 0, pdev->name, pdev);

		if (returnVal != 0) {
			dev_info(&pdev->dev, "Interrupt Could NOT Registered.\n");
		}
		else {
			printk(KERN_INFO "Interrupt Registered.\n");
		}
	}


	// Allocate mmap Area
	// The return value from the function is
	// a kernel virtual address for the buffer, which may be used by the driver;
	// the associated bus address, meanwhile, is returned in dma_handle.

	obj_dev->ds_axidma_addr =
	    dma_zalloc_coherent(NULL, DMA_LENGTH, &(obj_dev->ds_axidma_handle), GFP_KERNEL);


	list_add( &obj_dev->dev_list, &full_dev_list );
	return 0;
}

static int ds_axidma_pdrv_remove(struct platform_device *pdev)
{
	/* device destructor */
	struct list_head *pos, *q;
	list_for_each_safe( pos, q, &full_dev_list ) {
		struct ds_axidma_device *obj_dev;
    	obj_dev = list_entry( pos, struct ds_axidma_device, dev_list );
    	if (!my_strcmp(obj_dev->dev_name, pdev->name + 9))
    	{
    		list_del( pos );
    		cdev_del(&(obj_dev->c_dev));
    		device_destroy(cl, obj_dev->dev_num);
    		unregister_chrdev_region(obj_dev->dev_num, 1);
    		/* free mmap area */
			if (obj_dev->ds_axidma_addr) {
				dma_free_coherent(NULL, DMA_LENGTH, obj_dev->ds_axidma_addr, obj_dev->ds_axidma_handle);
			}

			free_irq(obj_dev->irq, pdev);

    		kfree(obj_dev);
    		break;
    	}
  	}
  	if (list_empty(&full_dev_list))
  	{
  		class_destroy(cl);
  	}



	printk(KERN_INFO "<%s> exit: unregistered\n", MODULE_NAME);
	return 0;
}

static int ds_axidma_pdrv_runtime_nop(struct device *dev)
{
	/* Runtime PM callback shared between ->runtime_suspend()
	 * and ->runtime_resume(). Simply returns success.
	 *
	 * In this driver pm_runtime_get_sync() and pm_runtime_put_sync()
	 * are used at open() and release() time. This allows the
	 * Runtime PM code to turn off power to the device while the
	 * device is unused, ie before open() and after release().
	 *
	 * This Runtime PM callback does not need to save or restore
	 * any registers since user space is responsbile for hardware
	 * register reinitialization after open().
	 */
	return 0;
}

static const struct dev_pm_ops ds_axidma_pdrv_dev_pm_ops = {
	.runtime_suspend = ds_axidma_pdrv_runtime_nop,
	.runtime_resume = ds_axidma_pdrv_runtime_nop,
};

static struct of_device_id ds_axidma_of_match[] = {
	{ .compatible = "ds_axidma", },
	{ /* This is filled with module_parm */ },
	{ /* Sentinel */ },
};
MODULE_DEVICE_TABLE(of, ds_axidma_of_match);
module_param_string(of_id, ds_axidma_of_match[1].compatible, 128, 0);
MODULE_PARM_DESC(of_id, "Openfirmware id of the device to be handled by uio");

static struct platform_driver ds_axidma_pdrv = {
	.probe = ds_axidma_pdrv_probe,
	.remove = ds_axidma_pdrv_remove,
	.driver = {
		.name = DRIVER_NAME,
		.owner = THIS_MODULE,
		.pm = &ds_axidma_pdrv_dev_pm_ops,
		.of_match_table = of_match_ptr(ds_axidma_of_match),
	},
};

module_platform_driver(ds_axidma_pdrv);

MODULE_AUTHOR("Fabrizio Spada, Gianluca Durelli");
MODULE_DESCRIPTION("AXI DMA driver");
MODULE_LICENSE("GPL v2");

