#ifndef INCLUDE_CVAR_H
#define INCLUDE_CVAR_H

#define FCVAR_ARCHIVE			(1<<0)	// set to cause it to be saved to vars.rc
#define FCVAR_USERINFO			(1<<1)	// changes the client's info string
#define FCVAR_SERVER			(1<<2)	// notifies players when changed
#define FCVAR_EXTDLL			(1<<3)	// defined by external DLL
#define FCVAR_CLIENTDLL			(1<<4)  // defined by the client dll
#define FCVAR_PROTECTED			(1<<5)  // It's a server cvar, but we don't send the data since it's a password, etc.  Sends 1 if it's not bland/zero, 0 otherwise as value
#define FCVAR_SPONLY			(1<<6)  // This cvar cannot be changed by clients connected to a multiplayer server.
#define FCVAR_PRINTABLEONLY		(1<<7)  // This cvar's string cannot contain unprintable characters ( e.g., used for player name etc ).
#define FCVAR_UNLOGGED			(1<<8)  // If this is a FCVAR_SERVER, don't log changes to the log file / console if we are creating a log
#define FCVAR_NOEXTRAWHITEPACE	(1<<9)  // strip trailing/leading white space from this cvar

typedef struct cvar_s
{
	const char *name;
	const char *string;
	int		flags;
	float	value;
	struct cvar_s *next;
} cvar_t;

#endif