/*
**  Copyright 2009 MERETHIS
**  This file is part of CentreonBroker.
**
**  CentreonBroker is free software: you can redistribute it and/or modify it
**  under the terms of the GNU General Public License as published by the Free
**  Software Foundation, either version 2 of the License, or (at your option)
**  any later version.
**
**  CentreonBroker is distributed in the hope that it will be useful, but
**  WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY
**  or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License
**  for more details.
**
**  You should have received a copy of the GNU General Public License along
**  with CentreonBroker.  If not, see <http://www.gnu.org/licenses/>.
**
**  For more information : contact@centreon.com
*/

#include <cstring>
#include <string>
#include "events/host_service_status.h"

using namespace CentreonBroker::Events;

/**************************************
*                                     *
*           Private Methods           *
*                                     *
**************************************/

/**
 *  Make a copy of all internal members of HostServiceStatus to the
 *  current instance.
 */
void HostServiceStatus::InternalCopy(const HostServiceStatus& hsse)
{
  memcpy(this->bools_, hsse.bools_, sizeof(this->bools_));
  memcpy(this->doubles_, hsse.doubles_, sizeof(this->doubles_));
  memcpy(this->ints_, hsse.ints_, sizeof(this->ints_));
  memcpy(this->shorts_, hsse.shorts_, sizeof(this->shorts_));
  for (unsigned int i = 0; i < STRING_NB; i++)
    this->strings_[i] = hsse.strings_[i];
  memcpy(this->timets_, hsse.timets_, sizeof(this->timets_));
  return ;
}

/**************************************
*                                     *
*           Public Methods            *
*                                     *
**************************************/

/**
 *  HostServiceStatus default constructor.
 */
HostServiceStatus::HostServiceStatus()
{
  memset(this->bools_, 0, sizeof(this->bools_));
  for (unsigned int i = 0; i < DOUBLE_NB; i++)
    this->doubles_[i] = 0.0;
  memset(this->ints_, 0, sizeof(this->ints_));
  memset(this->shorts_, 0, sizeof(this->shorts_));
  memset(this->timets_, 0, sizeof(this->timets_));
}

/**
 *  HostServiceStatus copy constructor.
 */
HostServiceStatus::HostServiceStatus(const HostServiceStatus& h)
  : Status(h)
{
  this->InternalCopy(h);
}

/**
 *  HostServiceStatus destructor.
 */
HostServiceStatus::~HostServiceStatus()
{
}

/**
 *  HostServiceStatus operator= overload.
 */
HostServiceStatus& HostServiceStatus::operator=(const
  HostServiceStatus& hsse)
{
  this->Status::operator=(hsse);
  this->InternalCopy(hsse);
  return (*this);
}

/**
 *  Get the acknowledgement_type member.
 */
short HostServiceStatus::GetAcknowledgementType() const throw ()
{
  return (this->shorts_[ACKNOWLEDGEMENT_TYPE]);
}

/**
 *  Get the active_checks_enabled member.
 */
bool HostServiceStatus::GetActiveChecksEnabled() const throw ()
{
  return (this->bools_[ACTIVE_CHECKS_ENABLED]);
}

/**
 *  Get the check_command member.
 */
const std::string& HostServiceStatus::GetCheckCommand() const throw ()
{
  return (this->strings_[CHECK_COMMAND]);
}

/**
 *  Get the check_interval member.
 */
double HostServiceStatus::GetCheckInterval() const throw ()
{
  return (this->doubles_[CHECK_INTERVAL]);
}

/**
 *  Get the check_period member.
 */
const std::string& HostServiceStatus::GetCheckPeriod() const throw ()
{
  return (this->strings_[CHECK_PERIOD]);
}

/**
 *  Get the check_type member.
 */
short HostServiceStatus::GetCheckType() const throw ()
{
  return (this->shorts_[CHECK_TYPE]);
}

/**
 *  Get the current_check_attempt member.
 */
short HostServiceStatus::GetCurrentCheckAttempt() const throw ()
{
  return (this->shorts_[CURRENT_CHECK_ATTEMPT]);
}

/**
 *  Get the current_notification_number member.
 */
short HostServiceStatus::GetCurrentNotificationNumber() const throw ()
{
  return (this->shorts_[CURRENT_NOTIFICATION_NUMBER]);
}

/**
 *  Get the current_state member.
 */
short HostServiceStatus::GetCurrentState() const throw ()
{
  return (this->shorts_[CURRENT_STATE]);
}

/**
 *  Get the event_handler member.
 */
const std::string& HostServiceStatus::GetEventHandler() const throw ()
{
  return (this->strings_[EVENT_HANDLER]);
}

/**
 *  Get the execution_time member.
 */
double HostServiceStatus::GetExecutionTime() const throw ()
{
  return (this->doubles_[EXECUTION_TIME]);
}

/**
 *  Get the has_been_checked member.
 */
bool HostServiceStatus::GetHasBeenChecked() const throw ()
{
  return (this->bools_[HAS_BEEN_CHECKED]);
}

/**
 *  Get the host_name member.
 */
const std::string& HostServiceStatus::GetHostName() const throw ()
{
  return (this->strings_[HOST_NAME]);
}

/**
 *  Get the is_flapping member.
 */
bool HostServiceStatus::GetIsFlapping() const throw ()
{
  return (this->bools_[IS_FLAPPING]);
}

/**
 *  Get the last_check member.
 */
time_t HostServiceStatus::GetLastCheck() const throw ()
{
  return (this->timets_[LAST_CHECK]);
}

/**
 *  Get the last_hard_state member.
 */
short HostServiceStatus::GetLastHardState() const throw ()
{
  return (this->shorts_[LAST_HARD_STATE]);
}

/**
 *  Get the last_hard_state_change member.
 */
time_t HostServiceStatus::GetLastHardStateChange() const throw ()
{
  return (this->timets_[LAST_HARD_STATE_CHANGE]);
}

/**
 *  Get the last_notification member.
 */
time_t HostServiceStatus::GetLastNotification() const throw ()
{
  return (this->timets_[LAST_NOTIFICATION]);
}

/**
 *  Get the last_state_change member.
 */
time_t HostServiceStatus::GetLastStateChange() const throw ()
{
  return (this->timets_[LAST_STATE_CHANGE]);
}

/**
 *  Get the last_update member.
 */
time_t HostServiceStatus::GetLastUpdate() const throw ()
{
  return (this->timets_[LAST_UPDATE]);
}

/**
 *  Get the latency member.
 */
double HostServiceStatus::GetLatency() const throw ()
{
  return (this->doubles_[LATENCY]);
}

/**
 *  Get the max_check_attempts member.
 */
short HostServiceStatus::GetMaxCheckAttempts() const throw ()
{
  return (this->shorts_[MAX_CHECK_ATTEMPTS]);
}

/**
 *  Get the modified_attributes member.
 */
int HostServiceStatus::GetModifiedAttributes() const throw ()
{
  return (this->ints_[MODIFIED_ATTRIBUTES]);
}

/**
 *  Get the next_check member.
 */
time_t HostServiceStatus::GetNextCheck() const throw ()
{
  return (this->timets_[NEXT_CHECK]);
}

/**
 *  Get the next_notification member.
 */
time_t HostServiceStatus::GetNextNotification() const throw ()
{
  return (this->timets_[NEXT_NOTIFICATION]);
}

/**
 *  Get the no_more_notifications member.
 */
bool HostServiceStatus::GetNoMoreNotifications() const throw ()
{
  return (this->bools_[NO_MORE_NOTIFICATIONS]);
}

/**
 *  Get the obsess_over member.
 */
bool HostServiceStatus::GetObsessOver() const throw ()
{
  return (this->bools_[OBSESS_OVER]);
}

/**
 *  Get the output member.
 */
const std::string& HostServiceStatus::GetOutput() const throw ()
{
  return (this->strings_[OUTPUT]);
}

/**
 *  Get the passive_checks_enabled member.
 */
bool HostServiceStatus::GetPassiveChecksEnabled() const throw ()
{
  return (this->bools_[PASSIVE_CHECKS_ENABLED]);
}

/**
 *  Get the percent_state_change member.
 */
double HostServiceStatus::GetPercentStateChange() const throw ()
{
  return (this->doubles_[PERCENT_STATE_CHANGE]);
}

/**
 *  Get the perf_data member.
 */
const std::string& HostServiceStatus::GetPerfData() const throw ()
{
  return (this->strings_[PERF_DATA]);
}

/**
 *  Get the problem_has_been_acknowledged member.
 */
bool HostServiceStatus::GetProblemHasBeenAcknowledged() const throw ()
{
  return (this->bools_[PROBLEM_HAS_BEEN_ACKNOWLEDGED]);
}

/**
 *  Get the retry_interval member.
 */
double HostServiceStatus::GetRetryInterval() const throw ()
{
  return (this->doubles_[RETRY_INTERVAL]);
}

/**
 *  Get the scheduled_downtime_depth member.
 */
short HostServiceStatus::GetScheduledDowntimeDepth() const throw ()
{
  return (this->shorts_[SCHEDULED_DOWNTIME_DEPTH]);
}

/**
 *  Get the should_be_scheduled member.
 */
bool HostServiceStatus::GetShouldBeScheduled() const throw ()
{
  return (this->bools_[SHOULD_BE_SCHEDULED]);
}

/**
 *  Get the state_type member.
 */
short HostServiceStatus::GetStateType() const throw ()
{
  return (this->shorts_[STATE_TYPE]);
}

/**
 *  Set the acknowledgement_type member.
 */
void HostServiceStatus::SetAcknowledgementType(short at) throw ()
{
  this->shorts_[ACKNOWLEDGEMENT_TYPE] = at;
  return ;
}

/**
 *  Set the active_checks_enabled member.
 */
void HostServiceStatus::SetActiveChecksEnabled(bool ace) throw ()
{
  this->bools_[ACTIVE_CHECKS_ENABLED] = ace;
  return ;
}

/**
 *  Set the check_command member.
 */
void HostServiceStatus::SetCheckCommand(const std::string& cc)
{
  this->strings_[CHECK_COMMAND] = cc;
  return ;
}

/**
 *  Set the check_interval member.
 */
void HostServiceStatus::SetCheckInterval(double ci) throw ()
{
  this->doubles_[CHECK_INTERVAL] = ci;
  return ;
}

/**
 *  Set the check_period member.
 */
void HostServiceStatus::SetCheckPeriod(const std::string& cp)
{
  this->strings_[CHECK_PERIOD] = cp;
  return ;
}

/**
 *  Set the check_type member.
 */
void HostServiceStatus::SetCheckType(short ct) throw ()
{
  this->shorts_[CHECK_TYPE] = ct;
  return ;
}

/**
 *  Set the current_check_attempt member.
 */
void HostServiceStatus::SetCurrentCheckAttempt(short cca) throw ()
{
  this->shorts_[CURRENT_CHECK_ATTEMPT] = cca;
  return ;
}

/**
 *  Set the current_notification_number member.
 */
void HostServiceStatus::SetCurrentNotificationNumber(short cnn) throw ()
{
  this->shorts_[CURRENT_NOTIFICATION_NUMBER] = cnn;
  return ;
}

/**
 *  Set the current_state member.
 */
void HostServiceStatus::SetCurrentState(short cs) throw ()
{
  this->shorts_[CURRENT_STATE] = cs;
  return ;
}

/**
 *  Set the event_handler member.
 */
void HostServiceStatus::SetEventHandler(const std::string& eh)
{
  this->strings_[EVENT_HANDLER] = eh;
  return ;
}

/**
 *  Set the execution_time member.
 */
void HostServiceStatus::SetExecutionTime(double et) throw ()
{
  this->doubles_[EXECUTION_TIME] = et;
  return ;
}

/**
 *  Set the has_been_checked member.
 */
void HostServiceStatus::SetHasBeenChecked(bool hbc) throw ()
{
  this->bools_[HAS_BEEN_CHECKED] = hbc;
  return ;
}

/**
 *  Set the host_name member.
 */
void HostServiceStatus::SetHostName(const std::string& hn)
{
  this->strings_[HOST_NAME] = hn;
  return ;
}

/**
 *  Set the is_flapping member.
 */
void HostServiceStatus::SetIsFlapping(bool i_f) throw ()
{
  this->bools_[IS_FLAPPING] = i_f;
  return ;
}

/**
 *  Set the last_check member.
 */
void HostServiceStatus::SetLastCheck(time_t lc) throw ()
{
  this->timets_[LAST_CHECK] = lc;
  return ;
}

/**
 *  Set the last_hard_state member.
 */
void HostServiceStatus::SetLastHardState(short lhs) throw ()
{
  this->shorts_[LAST_HARD_STATE] = lhs;
  return ;
}

/**
 *  Set the last_hard_state_change member.
 */
void HostServiceStatus::SetLastHardStateChange(time_t lhsc) throw ()
{
  this->timets_[LAST_HARD_STATE_CHANGE] = lhsc;
  return ;
}

/**
 *  Set the last_notification member.
 */
void HostServiceStatus::SetLastNotification(time_t ln) throw ()
{
  this->timets_[LAST_NOTIFICATION] = ln;
  return ;
}

/**
 *  Set the last_state_change member.
 */
void HostServiceStatus::SetLastStateChange(time_t lsc) throw ()
{
  this->timets_[LAST_STATE_CHANGE] = lsc;
  return ;
}

/**
 *  Set the last_update member.
 */
void HostServiceStatus::SetLastUpdate(time_t lu) throw ()
{
  this->timets_[LAST_UPDATE] = lu;
  return ;
}

/**
 *  Set the latency member.
 */
void HostServiceStatus::SetLatency(double l) throw ()
{
  this->doubles_[LATENCY] = l;
  return ;
}

/**
 *  Set the max_check_attempts member.
 */
void HostServiceStatus::SetMaxCheckAttempts(short mca) throw ()
{
  this->shorts_[MAX_CHECK_ATTEMPTS] = mca;
  return ;
}

/**
 *  Set the modified_attributes member.
 */
void HostServiceStatus::SetModifiedAttributes(int ma) throw ()
{
  this->ints_[MODIFIED_ATTRIBUTES] = ma;
  return ;
}

/**
 *  Set the next_check member.
 */
void HostServiceStatus::SetNextCheck(time_t nc) throw ()
{
  this->timets_[NEXT_CHECK] = nc;
  return ;
}

/**
 *  Set the next_notification member.
 */
void HostServiceStatus::SetNextNotification(time_t nn) throw ()
{
  this->timets_[NEXT_NOTIFICATION] = nn;
  return ;
}

/**
 *  Set the no_more_notifications member.
 */
void HostServiceStatus::SetNoMoreNotifications(bool nmn) throw ()
{
  this->bools_[NO_MORE_NOTIFICATIONS] = nmn;
  return ;
}

/**
 *  Set the obsess_over member.
 */
void HostServiceStatus::SetObsessOver(bool oo) throw ()
{
  this->bools_[OBSESS_OVER] = oo;
  return ;
}

/**
 *  Set the output member.
 */
void HostServiceStatus::SetOutput(const std::string& o)
{
  this->strings_[OUTPUT] = o;
  return ;
}

/**
 *  Set the passive_checks_enabled member.
 */
void HostServiceStatus::SetPassiveChecksEnabled(bool pce) throw ()
{
  this->bools_[PASSIVE_CHECKS_ENABLED] = pce;
  return ;
}

/**
 *  Set the percent_state_change member.
 */
void HostServiceStatus::SetPercentStateChange(double psc) throw ()
{
  this->doubles_[PERCENT_STATE_CHANGE] = psc;
  return ;
}

/**
 *  Set the perf_data member.
 */
void HostServiceStatus::SetPerfData(const std::string& p)
{
  this->strings_[PERF_DATA] = p;
  return ;
}

/**
 *  Set the problem_has_been_acknowledged member.
 */
void HostServiceStatus::SetProblemHasBeenAcknowledged(bool phba) throw ()
{
  this->bools_[PROBLEM_HAS_BEEN_ACKNOWLEDGED] = phba;
  return ;
}

/**
 *  Set the retry_check_interval member.
 */
void HostServiceStatus::SetRetryInterval(double ri) throw ()
{
  this->doubles_[RETRY_INTERVAL] = ri;
  return ;
}

/**
 *  Set the scheduled_downtime_depth member.
 */
void HostServiceStatus::SetScheduledDowntimeDepth(short sdd) throw ()
{
  this->shorts_[SCHEDULED_DOWNTIME_DEPTH] = sdd;
  return ;
}

/**
 *  Set the should_be_scheduled member.
 */
void HostServiceStatus::SetShouldBeScheduled(bool sbs) throw ()
{
  this->bools_[SHOULD_BE_SCHEDULED] = sbs;
  return ;
}

/**
 *  Set the state_type member.
 */
void HostServiceStatus::SetStateType(short st) throw ()
{
  this->shorts_[STATE_TYPE] = st;
  return ;
}
