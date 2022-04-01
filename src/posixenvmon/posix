#include <stdio.h>
#include <thread.h>
#include <sys/time.h>
#include <sys/select.h>
#include <sys/queue.h>
#include <cache.h>
#include <cache_callbcaks.h>

# We are going to use shared cache
# Mange our memory footprint for
# embedded devices
# Want to incorporate this posix
# file monitoring and shared mem and cache

#define MaxFilesMonitoring  3
#define MaxBuffsz           512

struct timespec


char *FileListeners[MaxFiles];

enum eEvent{enumFileDataReceived,  enumEvntConnect, enumDataToRead, 
    enumDataToWrite, enumException);

typedef eEvent fd_evnt;

typedef struct
{
    uint16_t     readpos;
    int     writepos;
    char    ReadBuff[MaxBuffsz];
    char    WriteBuff[MaxBuffsz];
    int     nfds;
    char    fileName[512];
    fd_set* rwefd[3];
} fileListener_t;

typedef fileListener_t*  connection;


int InitNewConntion(fileListener* newFileMonitorConn)
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
     cache_create(newFileMonitorConn.filename. im_cache", &attrs, &im_cache);
     fileListener_t*  connection;
}

int main()
{
    thread_t listenThread = pthread_create(listenThread, &startlister);
    listenThread.join();
    return 0;
}


int startlistener()
{
    int pselret;

    while( pselect(int nfds, fd_set *restrict readfds,
        fd_set *restrict writefds, fd_set *restrict errorfds,
        const struct timespec *restrict timeout,
        const sigset_t *restrict sigmask)
    {
        for(int i=0;i <MAXFILEMON; i++)
        {
            enumEvntif(findTriggeredEvent(fileListener[i]));
            if(findTriggeredEvent(fileListener[ii, &fd_evnt]))
            {

                switch(eEvent)
                {

                case(aenumFileDataReceived):

                ReadFromFile(fileListener[i]);


                break;

                case(enumFileDataReceived):
                break;
                case(enumEvntConnect):
                break;
                case(enumDataToRead):
                break;
                case(enumDataToWrite):
                break;
                case(enumException):
                break;
                }
            }

bool IsConnected(fileListener* fl)
{
    if (fileListener != NUL 
}
int newfilelistener()
{
    for(int i=0;i <MAXFILEMON; i++)
    {
        if (fileListener[i].nfds==0)
        {
            //Found an empty spot in the array of Files Being Monitored
            fileListener[i]= (fileListener_t*) calloc(sizeof(fileListener_t));
           InitConnntion( ();
        }
    }
}

int fdset_reset()
{
    fd_set  nfds, readfds, writefds, errorfds;

    FD_SET( int fd, fd_set * fdset );
    FD_CLR( int fd, fd_set * fdset );
    FD_ISSET( int fd, fd_set * fdset );
    FD_ZERO( fd_set * fdset );

    return 0;
}

int ReadFromFile(fileListener[i])
{
    return 0;
}

int processdata()
{

    return 0;
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
