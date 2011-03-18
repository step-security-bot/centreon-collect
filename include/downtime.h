/*
** Copyright 2001-2005 Ethan Galstad
** Copyright 2011      Merethis
**
** This file is part of Centreon Scheduler.
**
** Centreon Scheduler is free software: you can redistribute it and/or
** modify it under the terms of the GNU General Public License version 2
** as published by the Free Software Foundation.
**
** Centreon Scheduler is distributed in the hope that it will be useful,
** but WITHOUT ANY WARRANTY; without even the implied warranty of
** MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
** General Public License for more details.
**
** You should have received a copy of the GNU General Public License
** along with Centreon Scheduler. If not, see
** <http://www.gnu.org/licenses/>.
*/

#ifndef DOWNTIME_H
# define DOWNTIME_H

# include "config.h"
# include "common.h"
# include "objects.h"

# ifdef __cplusplus
  extern "C" {
# endif

/* SCHEDULED_DOWNTIME_ENTRY structure */
typedef struct scheduled_downtime_struct{
	int type;
	char *host_name;
	char *service_description;
	time_t entry_time;
	time_t start_time;
	time_t end_time;
	int fixed;
	unsigned long triggered_by;
	unsigned long duration;
	unsigned long downtime_id;
	char *author;
	char *comment;
	unsigned long comment_id;
	int is_in_effect;
	int start_flex_downtime;
	int incremented_pending_downtime;
	struct scheduled_downtime_struct *next;
	}scheduled_downtime;



int initialize_downtime_data(char *);                                /* initializes scheduled downtime data */
int cleanup_downtime_data(char *);                                   /* cleans up scheduled downtime data */

int add_new_downtime(int,char *,char *,time_t,char *,char *,time_t,time_t,int,unsigned long,unsigned long,unsigned long *);
int add_new_host_downtime(char *,time_t,char *,char *,time_t,time_t,int,unsigned long,unsigned long,unsigned long *);
int add_new_service_downtime(char *,char *,time_t,char *,char *,time_t,time_t,int,unsigned long,unsigned long,unsigned long *);

int delete_host_downtime(unsigned long);
int delete_service_downtime(unsigned long);
int delete_downtime(int,unsigned long);

int schedule_downtime(int,char *,char *,time_t,char *,char *,time_t,time_t,int,unsigned long,unsigned long,unsigned long *);
int unschedule_downtime(int,unsigned long);

int register_downtime(int,unsigned long);
int handle_scheduled_downtime(scheduled_downtime *);
int handle_scheduled_downtime_by_id(unsigned long);

int check_pending_flex_host_downtime(host *);
int check_pending_flex_service_downtime(service *);

int check_for_expired_downtime(void);

int add_host_downtime(char *,time_t,char *,char *,time_t,time_t,int,unsigned long,unsigned long,unsigned long);
int add_service_downtime(char *,char *,time_t,char *,char *,time_t,time_t,int,unsigned long,unsigned long,unsigned long);

/* If you are going to be adding a lot of downtime in sequence, set
   defer_downtime_sorting to 1 before you start and then call
   sort_downtime afterwards. Things will go MUCH faster. */

extern int defer_downtime_sorting;
int add_downtime(int,char *,char *,time_t,char *,char *,time_t,time_t,int,unsigned long,unsigned long,unsigned long);
int sort_downtime(void);

scheduled_downtime *find_downtime(int,unsigned long);
scheduled_downtime *find_host_downtime(unsigned long);
scheduled_downtime *find_service_downtime(unsigned long);

void free_downtime_data(void);                                       /* frees memory allocated to scheduled downtime list */

# ifdef __cplusplus
  }
# endif

#endif /* !DOWNTIME_H */
