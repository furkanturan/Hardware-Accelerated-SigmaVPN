
#include <linux/kernel.h>
#include <linux/module.h>       /* for module_init, module_exit */
#include <linux/fs.h>           /* for fops */
#include <asm/io.h>             /* for IO Read/Write Functions */

#include <linux/cdev.h>         /* for cdev */
#include <linux/dma-mapping.h>  /* for vm_operations_struct, vm_area_struct */
#include <linux/slab.h>         /* for kmalloc */


#define SUCCESS             0

/* Dev name as it appears in /proc/devices   */
#define DEVICE_NAME         "ds_axidma"	

#define DMA_SIZE            0x10000
#define DMA_BASE            0x40400000
 
#define MM2S_SRC_ADD_REG    0x18
#define S2MM_DST_ADR_REG    0x48

struct dma_buffer {
    void               *cpu_addr;
    size_t             size;
    dma_addr_t         dma_addr;
    void               *priv_data;
};

struct dma_dev {
    struct cdev         cdev;  

    phys_addr_t         bus_addr;
    unsigned long       bus_size;
    const char          *dev_name;

    char                *virt_bus_addr;
    dev_t               dev_num;

    struct dma_buffer   dma_buf;
};

/* Global variable for the device class */
static struct class *cl;	

struct dma_dev *dev;

////////////////////////////////////////////////////////////////////////////////

/* Called when a process, which already opened the dev file, attempts to
 * read from it.
 */
static ssize_t 
device_read(struct file *filp, char *buffer, size_t length,	loff_t * offset)
{
	printk(KERN_ALERT "Sorry, this operation isn't supported.\n");
	return -EINVAL;
}

////////////////////////////////////////////////////////////////////////////////

/* Called when a process writes to dev file: echo "hi" > /dev/hello 
 */
static ssize_t
device_write(struct file *filp, const char *buff, size_t len, loff_t * off)
{    
    struct dma_buffer *buf;
    
    buf = &dev->dma_buf;
    
    iowrite32(  buf->dma_addr, 
                dev->virt_bus_addr + MM2S_SRC_ADD_REG);
                
	iowrite32(  buf->dma_addr, 
                dev->virt_bus_addr + S2MM_DST_ADR_REG);
    
    
    /* enable user-mode access to the performance counter*/
	asm ("MCR p15, 0, %0, C9, C14, 0\n\t" :: "r"(1));
	/* disable counter overflow interrupts (just in case)*/
	asm ("MCR p15, 0, %0, C9, C14, 2\n\t" :: "r"(0x8000000f));
    
	printk(KERN_ALERT "Performance Counters are opened");
    
    return -EINVAL;
}

////////////////////////////////////////////////////////////////////////////////

/* Called when a process tries to open the device file, like
 * "cat /dev/mycharfile"
 */
static int device_open(struct inode *inode, struct file *file)
{       
    if (request_mem_region ( dev->bus_addr,
                             dev->bus_size,
                             DEVICE_NAME) == NULL)
    {
        return 1;
    }

    dev->virt_bus_addr = (char*)ioremap_nocache( dev->bus_addr,     
                                                 dev->bus_size);     
    
	return 0;
}

////////////////////////////////////////////////////////////////////////////////

/* Close the file and there's nothing to do for it
 */
static int device_release(struct inode *inode, struct file *file)
{
	return 0;
}

////////////////////////////////////////////////////////////////////////////////

struct vm_operations_struct dma_dev_vma_ops = {};

static int mmap_DMA_Control(struct file *filp, struct vm_area_struct *vma)
{    
    size_t size;
    
    size = vma->vm_end - vma->vm_start;
    
    vma->vm_ops = &dma_dev_vma_ops;
    vma->vm_page_prot = pgprot_noncached(vma->vm_page_prot);
    vma->vm_private_data = dev;
    
    if (remap_pfn_range(vma, 
                        vma->vm_start,
                        vmalloc_to_pfn(dev->virt_bus_addr),
                        size, 
                        vma->vm_page_prot))
        return -EAGAIN;

    return SUCCESS;
}

struct vm_operations_struct dma_buffer_ops = {};

static int mmap_DMA_Buffer(struct file *file_p, struct vm_area_struct *vma)
{
    struct dma_buffer *buf;
    size_t size;
            
    size = vma->vm_end - vma->vm_start;    
    
    buf = &dev->dma_buf;
    
    buf->cpu_addr = NULL;
    
    buf->cpu_addr = dma_zalloc_coherent(NULL, 
                                        size, 
                                        &(buf->dma_addr),
                                        GFP_KERNEL);
    if (buf->cpu_addr == NULL)
        return -ENOMEM;
    
    memcpy(buf->cpu_addr, &buf->dma_addr, sizeof(buf->dma_addr));
    
    buf->size = size;
    buf->priv_data = dev;
    vma->vm_ops = &dma_buffer_ops;
    vma->vm_page_prot = pgprot_noncached(vma->vm_page_prot);
    vma->vm_private_data = buf;
    
    if (remap_pfn_range(vma, 
                        vma->vm_start,
                        vmalloc_to_pfn(buf->cpu_addr),
                        size, 
                        vma->vm_page_prot))
    {
        dma_free_coherent(NULL,
                          buf->size, 
                          buf->cpu_addr,
                          buf->dma_addr);
                          
        buf->cpu_addr = NULL;        
        return -EAGAIN;
    }
    
    return SUCCESS;
}

/*
 * Page offset has special meaning:
 *
 * 1) '0' means uncached mmap for DMA's Control Registers
 * 2) '1' means coherent DMA buffer.
 * 3) else is undefined.
 */
static int device_mmap(struct file *file_p, struct vm_area_struct *vma)
{       
    if (vma->vm_pgoff == 0) 
    {
        return  mmap_DMA_Control(file_p, vma);
    } 
    else if (vma->vm_pgoff == 1) 
    {
        return mmap_DMA_Buffer(file_p, vma);
    } 
    else 
    {
        return -EINVAL;
    }    
}

////////////////////////////////////////////////////////////////////////////////

static struct file_operations fops = {
	.owner = THIS_MODULE,
	.read = device_read,
	.write = device_write,
	.open = device_open,
	.release = device_release,
    .mmap = device_mmap,
};

////////////////////////////////////////////////////////////////////////////////

/* This function is called when the module is loaded
 */
int __init init_module(void)
{
    
    // http://opensourceforu.efytimes.com/2011/04/character-device-files-creation-operations/
    
    // struct dma_dev *dev = (struct dma_dev *)
    dev = (struct dma_dev *) kmalloc( sizeof(struct dma_dev), GFP_KERNEL);
    
    dev->bus_addr = DMA_BASE;
    dev->bus_size = DMA_SIZE;
	dev->dev_name = DEVICE_NAME;
    
    printk(KERN_INFO "DMA DRIVER: Init - Registered\n");
    if (alloc_chrdev_region(&(dev->dev_num), 0, 1, DEVICE_NAME) < 0)
    {
        return -1;
    }
    if (cl == NULL && (cl = class_create(THIS_MODULE, "chardrv")) == NULL)
    {        
        unregister_chrdev_region(dev->dev_num, 1);
        return -1;
    }
    if (device_create(cl, NULL, dev->dev_num, NULL, DEVICE_NAME) == NULL)
    {        
        class_destroy(cl);
        unregister_chrdev_region(dev->dev_num, 1);
        return -1;
    }
    
    cdev_init(&(dev->cdev), &fops);
    if (cdev_add(&(dev->cdev), dev->dev_num, 1) == -1)
    {        
        device_destroy(cl, dev->dev_num);
        class_destroy(cl);
        unregister_chrdev_region(dev->dev_num, 1);
        return -1;
    }    
        return SUCCESS;
}

/*
 * This function is called when the module is unloaded
 */
void __exit cleanup_module(void)
{
    cdev_del(&(dev->cdev));
    
    device_destroy(cl, dev->dev_num);
    class_destroy(cl);
    unregister_chrdev_region(dev->dev_num, 1);
    printk(KERN_INFO "DMA DRIVER: Unregistered");
}

module_init(init_module);
module_exit(cleanup_module);


MODULE_AUTHOR("Furkan Turan");
MODULE_VERSION("0.0.1");
MODULE_DESCRIPTION("NaCl DMA Driver");
MODULE_LICENSE("GPL");