#include <stdio.h>
#include <unistd.h>
#include <thread.h>
#include <sys/select.h>
#include <sys/queue.h>
#include <cache.h>
#include <cache_callbcaks.h>

# We are going to use shared cache
# Mange our memory footprint for
# embedded devices
# Want to incorporate this posix
# file monitoring and shared mem and cache

#define MAXFILES            3
#define MAXFILECONNS        20
#define MAXFILENAMESZ       256
#define MAXBUFFSZ           512
#define STR2(x)             #x
#define STR(X)              STR2(X)


enum erwefds { READFDS=0, WRITEFDS=1, ERRORFDS=2, STDIN};
enum edata { FILEDATARECEIVE, CONNECT, DATAREAD, DATAWRITE, EXCEPTION};

int const NUMFLDS = STDIN;

const struct timespec *restrict timeout;
const sigset_t *restrict sigmask;

typedef erwefds fd_event;
typedef edata   data_event;

struct fileListener
{
    u_int16_t   readPos;
    u_int16_t   writePos;
    char        readBuff[MAXBUFFSZ];
    char        writeBuff[MAXBUFFSZ];
    int         nfds;
    char        fileName[MAXBUFFSZ];
    int         fd_file;
    fd_set*     rweFDS[NUMFDS];
};
typedef struct fileListener FileListener;

struct flconnections
{
    FileListener*   fileListenerConnections[MAXFILES];
    int             fd_stdin;
    u_int16_t       maxFDS;
};
typedef struct flconnections Connections;

struct _thread_info {
	pthread_t thread_id;
	volatile int can_capture;
	volatile int can_process;
    volatile int bMonitorOn;
	int readfd;
	int format;
	Connections conns;
};
typedef struct _thread_info pm_thread_info_t;


pthread_mutex_t io_thread_lock = PTHREAD_MUTEX_INITIALIZER;
pthread_cond_t  data_ready = PTHREAD_COND_INITIALIZER;


int InitConnntion(FileListener* newFileMonitorConn)
{
     cache_t *im_cache;
     cache_attributes_t attrs = {
         .version = CACHE_ATTRIBUTES_VERSION_2,
         .key_hash_cb = cache_key_hash_cb_cstring,
         .key_is_equal_cb = cache_key_is_equal_cb_cstring,
         .key_retain_cb = my_copy_string,
         .key_release_cb = cache_release_cb_free,
         .value_release_cb  = cache_release_cb_free,
     };
     cache_create("com.acme. im_cache", &attrs, &im_cache);
}

int main(int argc, char **argv)
{
    int i=0;
    if (argcnt > i)
    {
        initMonitor();
        uint_16_t fsz = strlen(argstr)+1>MaxFileSize?MaxFileSize:strlen(argstr)+1;
        pthread_attr_t *attr=NULL;
        
        pm_thread_info_t thread_info;
        pm_thread_info_t *info = &thread_info;
        memset(&thread_info, 0, sizeof(thread_info));
	    thread_info.rb_size = 16384 * 4;
	    thread_info.readfd = fileno(stdin);

        thread_t listenThread = pthread_create(listenThread, attr, &listenerthread, info);
        char cmd[MAXFILENAMESZ];
        while(thread_info.bMonitorOn)
            parsecmdln();
        
        listenThread.join();
    }
    return 0;
}

int parseinputcommands(){

}

int initMonitor()
{
    Connections = malloc(sizeof(Connections *));
    Connections.maxFDS = 0;
    for (int i=0; i<=MAXFILECONNS; i++)
        Connections.fileListenerConnections[i]=malloc(sizeof(FileListener));
    bMonitorOn=1;
    return 0;
}

int listenerthread()
{
    int pselret=1;

    while( pselret > 0)
    {
        pselret = pselect(maxfds, conn->rwefd[0], conn->rwefd[1], conn->rwefd[2], timeout, sigmask)

        if(pselret == -1)
        {
            printf("Received error pselect listenthread.  Exit.");
            processerror();
            return -1;
        }

        Connections.maxFDS = findTriggeredEvents();

        fdset_reset();
    }
    return 0;
}

bool IsConnected(fileListener* fl)
{
    if (fl != NULL && fl->nfds > 0)
        return true;

    return false;
}

int newfilelistener(char *filename)
{
    for(int i=0; i <MAXFILEMON; i++)
    {
        if (IsConnected(Connections.fileListenerConnections[i]) == 0)
        {
            //Found an empty spot in the array of Files Being Monitored
            Connections.fileListenerConnections[i] = (fileListener_t*) calloc(sizeof(fileListener_t));
            InitConnntion(Connections.fileListenerConnections[i] );
            sprintf(Connections.fileListenerConnections[i].fileName, "%s", filename);
            free filename;
            Connections.fileListenerConnections[i].fd_file = open(Connections.fileListenerConnections[i].fileName, O_RDONLY);
            if(Connections.fileListenerConnections[i].fd_file == -1)
            {
                printf("newfilelistener::Error: Could not open file: %s.\n",Connections.fileListenerConnections[i].fileName);
                return -1;
            }
        }
    }
    return 0;
}

int findtriggeredevents()
{
    if(FD_ISSET(0, &Connections->stdinfds))
        processStdInCmd();

    for( int i=0; i < MAXFILECONNS; i++)
    {
        FileListener *fl = Connections.fileListenerConnections[i];

        if (FD_ISSET(fl->fd_file, &fl->rwefds[READFDS]))
            processdata(fl->fd_file,READFDS);

        if (FD_ISSET(fl->fd_file, &fl->rwefds[WRITEFDS]))
            writedata(fl->fd_file, WRITEFDS);

        if( FD_ISSET(fl->fd_file, &fl->rwefds[ERRORFDS]))
            processerror(fl->fd_file, ERRORFDS);
            
        fdset_reset(fl[i]);
    }
    return 0;
}

int fdset_reset()
{
    for( int i=0; i < MAXFILECONNS; i++)
    {
        Connections.

        FD_ZERO(&conn->rwefds[STDINPUT]);
        FD_ZERO(&conn->rwefds[READFDS]);
        FD_ZERO(&conn->rwefds[WRITEFDS]);
        FD_ZERO(&conn->rwefds[ERRORFDS]);

        /* Watch stdin (fd 0) to see when it has input. */
        FD_SET(0, &conn->rwefds[STDINPUT]);
        FD_SET(conn->fd_file, &conn->rwefds[READFDS]);
        FD_SET(conn->fd_file, &conn->rwefds[WRITEFDS]);
        FD_SET(conn->fd_file, &conn->rwefds[ERRORFDS]);

        max_fd = (fd_2 > fd_1 ? fd_2 : fd_1) + 1;

        FD_SET  (   conn->nfds,     conn->rwefds[READFDS], conn-> );
        FD_CLR  (   conn->nfds,     conn->rwefds[WRITEFDS] );
        FD_ISSET(   conn->nfds,     conn->rwefds[ERRORFDS] );
        FD_ZERO (   conn->rwefds[2] );

        if (conn->nfds > FileListeners.maxFDS)
            FileListeners.maxFDS = conn->nfds;
    }

    return FileListeners.maxFDS;
}

int processdata(int fd, fd_event eventType)
{
    if ((info->can_process) && fd > 2)
    {
        /* Tell the io thread there that frames have been dequeued. */
	    if (pthread_mutex_trylock(&io_thread_lock) == 0) 
        {

            switch(eventType)
            {
                case READFDS:
                    readfromfile(fd);
                    break;
                case WRITEFDS:
                    writetofile(fd);
                    break;
                case ERRORFDS:
                    handleerror(fd);
                    break;
                case STDINPUT:
                    printf("STDINPUT: Process Command Line Input.");
                    processstdin(fd);
                    break;
                default:
                    printf("Error: Unhandled Event Triggered.");
                    break;
        }
        pthread_mutex_unlock(&io_thread_lock);
    }
    return 0;
}

int processStdInCmd()
{
    int opt;
    char *fn = NULL;
    FILE *pointerFile = stdin;  /* set 'stdin' by default */

    while ((opt = getopt (argc, argv, "a::b:")) != -1) {
        switch (opt) {
            case 'a' :  /* open file if given following -a on command line */
                if (!optarg) break;     /* if nothing after -a, keep stdin */
                fn = argv[optind - 1];
                pointerFile = fopen (fn, "r");
                break;
            case 'b' :; /* do whatever */
                break;
            default :   /* ? */
                fprintf (stderr, "\nerror: invalid or missing option.\n");
        }
    }
    /* handle any arguments that remain from optind -> argc
     * for example if 'fizzle.exe textfile.txt' given, read from
     * textfile.txt instead of stdin.
     */
    if (pointerFile == stdin && argc > optind) {
        fn = argv[optind++];
        pointerFile = fopen (fn, "r");
    }

    printf ("\n fizzle.txt reads : %s\n\n", pointerFile == stdin ? "stdin" : fn);

    return 0;

    char cmd[MAXFILENAMESZ];
    
    while(bMonitorOn)
        parsecmdln();

    return 0;

}


int writedata(int fd, fd_event eventType)
{
    return FileListeners.maxFDS;
}

int processerror(int fd, fd_event eventType)
{
pthread_mutex_unlock(&io_thread_lock);
     [EAGAIN]           The kernel was (perhaps temporarily) unable to allocate the requested
                        number of file descriptors.

     [EBADF]            One of the descriptor sets specified an invalid descriptor.

     [EINTR]            A signal was delivered before the time limit expired and before any
                        of the selected events occurred.

     [EINVAL]           The specified time limit is invalid.  One of its components is
                        negative or too large.

     [EINVAL]

}
int cache_create(const char *name, cache_attributes_t *attrs, cache_t **cache_out)
{
    return 0;
}

int cache_destroy(cache_t *cache)
{
    return 0;
}

int cache_cache()
{
    retunrn 0;
}

int savetofile(char *svfname)
{
    //Save the current filename to svfname

    return 0;
}

void catchsig (int sig) {
#ifndef _WIN32
	signal(SIGHUP, catchsig); /* reset signal */
	signal(SIGINT, catchsig); /* reset signal */
#endif
	if (!want_quiet)
		fprintf(stderr,"\n jack-stdin: CAUGHT SIGNAL - shutting down.\n");
	run=0;
	/* signal reader thread */
	//pthread_mutex_lock(&io_thread_lock);
	//pthread_cond_signal(&data_ready);
	//pthread_mutex_unlock(&io_thread_lock);
}

int parsecmdln()
{
    const char *optstring = "d:e:b:S:f:p:n:BLhq";
	struct option long_options[] = {
		{ "help", 0, 0, 'h' },
		{ "exit", 1, 0, 'e' },
		{ "quit", 1, 0, 'q' },
		{ "file", 1, 0, 'f' },
		{ "name", 1, 0, 'n' },
		//{ "prebuffer", 1, 0, 'p' },
		//{ "little-endian", 0, 0, 'L' },
		//{ "big-endian", 0, 0, 'B' },
		//{ "bitdepth", 1, 0, 'b' },
		{ "save", 1, 0, 's' },
		{ 0, 0, 0, 0 }
	};

	while ((c = getopt_long(argc, argv, optstring, long_options, NULL)) != -1) {
		switch (c) {
			case 'h':
				usage(argv[0], 0);
				break;
			case 'f':
				free(infn);
				infn=strdup(optarg);
				break;
			case 'n':
				client_name = optarg;
				break;
			case 'd':
				thread_info.duration = atoi(optarg);
				break;
			case 'p':
				thread_info.prebuffer = atof(optarg);
				if (thread_info.prebuffer<1.0) thread_info.prebuffer=0.0;
				if (thread_info.prebuffer>90.0) thread_info.prebuffer=90.0;
				break;
			case 'e':
			case 'q':
				fprintf(stderr, "(bMonitorOn=0) shutting down the monitor.\n");
				bMonitorOn=0;
                break;
			case 's':
                svfn=strdup(optarg);
                savetofile(svfn);
				break;
			default:
				fprintf(stderr, "invalid argument.\n");
				usage(argv[0], 0);
				break;
		}
	}

	/* set options depending on JACK params, and perform sanity checks */
	if (IS_FMTFLT) {
		/* float is always 32 bit */
		thread_info.format|=3;
	}

	if (argc <= optind) {
		fprintf(stderr, "At least one port/audio-channel must be given.\n");
		usage(argv[0], 1);
	}

	if (infn) {
		thread_info.readfd = open(infn, O_RDONLY) ;
		if (thread_info.readfd <0) {
			fprintf(stderr, "Can not open file.\n");
			exit(1);
		}
	}

	/* set up JACK client */
	if ((client = jack_client_open(client_name, JackNoStartServer, &jstat)) == 0) {
		fprintf(stderr, "Can not connect to JACK.\n");
		exit(1);
	}

	thread_info.client = client;
	thread_info.can_process = 0;
	thread_info.channels = argc - optind;

	if (thread_info.duration > 0) {
		thread_info.duration *= jack_get_sample_rate(thread_info.client);
	}

	/* bail out if buffer is smaller than twice the jack period */
	if ((thread_info.rb_size>>1) < jack_get_buffer_size(thread_info.client)) {
		fprintf(stderr, "Ringbuffer size needs to be at least twice jack period size\n");
		jack_client_close(thread_info.client);
		usage(argv[0], 1);
	}

	/* when using small buffers: check if pre-buffer is not too large */
	if ( thread_info.rb_size - ceil(thread_info.rb_size * thread_info.prebuffer /100.0)
			< jack_get_buffer_size(thread_info.client)
		 ) {
		fprintf(stderr, "Prebuffer ratio is too high. It will never finish.\n");
		jack_client_close(thread_info.client);
		usage(argv[0], 1);
	}

	jack_set_process_callback(client, process, &thread_info);
	jack_on_shutdown(client, jack_shutdown, &thread_info);

	if (jack_activate(client)) {
		fprintf(stderr, "cannot activate client");
	}

	setup_ports(thread_info.channels, &argv[optind], &thread_info);

	pthread_create(&thread_info.thread_id, NULL, io_thread, &thread_info);
#ifndef _WIN32
	signal(SIGHUP, catchsig);
	signal(SIGINT, catchsig);
#endif
}

static void usage (const char *name, int status) {
	fprintf(status?stderr:stdout,
		"usage: %s [ OPTIONS ] port1 [ port2 ... ]\n", name);
	fprintf(status?stderr:stdout,
		"posixenvmon monitors environment variables and other files for changes.\n");
	fprintf(status?stderr:stdout,
	  "OPTIONS:\n"
	  " -h, --help               print this message\n"
	  " -q, --quiet              inhibit usual output\n"
	  " -b, --bitdepth {bits}    choose integer bit depth: 16, 24 (default: 16)\n"
	  " -d, --duration {sec}     terminate after given time, <1: unlimited (default:0)\n"
	  " -e, --encoding {format}  set output format: (default: signed)\n"
		"                          signed-integer, unsigned-integer, float\n"
	  " -f, --file {filename}    read data from file instead of stdin\n"
	  " -n, --name {clientname}  set client name in JACK instead of jstdin\n"
	  " -p, --prebuffer {pct}    Pre-fill the buffer before starting audio output\n"
		"                          to JACK (default 50.0%%).\n"
	  " -L, --little-endian      write little-endian integers or\n"
		"                          native-byte-order floats (default)\n"
	  " -B, --big-endian         write big-endian integers or swapped-order floats\n"
	  " -S, --bufsize {samples}  set buffer size (default: 64k)\n"
		);
	exit(status);
}
