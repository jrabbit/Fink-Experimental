#include <sys/types.h>
#include <unistd.h>
#include <mach-o/loader.h>
#include <fcntl.h>
#include <stdio.h>

static void 
print_mhflags(unsigned long flags)
{
	if (flags & MH_NOUNDEFS)
		printf("NOUNDEFS ");
	if (flags & MH_INCRLINK)
		printf("INCRLINK ");
	if (flags & MH_DYLDLINK)
		printf("DYLDLINK ");
	if (flags & MH_BINDATLOAD)
		printf("BINDATLOAD ");
	if (flags & MH_PREBOUND)
		printf("PREBOUND ");
	if (flags & MH_SPLIT_SEGS)
		printf("SPLIT_SEGS ");
	if (flags & MH_LAZY_INIT)
		printf("LAZY_INIT ");
	if (flags & MH_TWOLEVEL)
		printf("TWOLEVEL ");
	if (flags & MH_FORCE_FLAT)
		printf("FORCE_FLAT ");
	if (flags & MH_NOMULTIDEFS)
		printf("NOMULTIDEFS ");
	if (flags & MH_NOFIXPREBINDING)
		printf("NOFIXPREBINDING ");
}

int 
main(int argc, char *argv[])
{
	int             error_status = 0, little_endian = 0;
	if (argc == 0)
		return 1;
	for (int i = 1; i <= argc; i++) {
		struct mach_header mh;
		int             fd = open(argv[i], O_RDONLY);
		int             err;
		fcntl(fd, F_NOCACHE, 1);
		if (fd == -1) {
			error_status = 1;
			continue;
		}
		err = read(fd, &mh, sizeof(mh));
		close(fd);
		if (err == -1) {
			error_status = 1;
			continue;
		}
		unsigned long   mh_flags;
		if (mh.magic != MH_MAGIC) {
			if (mh.magic == MH_CIGAM)
				little_endian = 1;
			else {
				error_status = 1;
				continue;
			}
		}
		mh_flags = little_endian ? NXSwapInt(mh.flags) : mh.flags;
		if (!(mh_flags & MH_PREBOUND)) {
			printf("%s: ", argv[i]);
			print_mhflags(mh_flags);
			printf("\n");
		}
	}
	return error_status;
}
