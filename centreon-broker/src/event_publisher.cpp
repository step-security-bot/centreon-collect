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

#include <cassert>
#include <cstdlib>
#include "event_publisher.h"
#include "event_subscriber.h"
#include "events/event.h"

using namespace CentreonBroker;

/**************************************
*                                     *
*           Static Members            *
*                                     *
**************************************/

EventPublisher* EventPublisher::instance_ = NULL;
boost::mutex    EventPublisher::instancem_;

/**************************************
*                                     *
*           Private Methods           *
*                                     *
**************************************/

/**
 *  \brief EventPublisher constructor.
 *
 *  As the EventPublisher is a singleton, the constructor is declared private.
 *  Initialization is made through the first call to GetInstance().
 *
 *  \see GetInstance
 */
EventPublisher::EventPublisher()
{
}

/**
 *  \brief EventPublisher copy constructor.
 *
 *  EventPublisher shouldn't be copied, so the copy constructor is declared
 *  private.
 *
 *  \param ep Unused.
 */
EventPublisher::EventPublisher(const EventPublisher& ep)
{
  (void)ep;
  assert(false);
}

/**
 *  \brief Overload of the assignement operator.
 *
 *  EventPublisher shouldn't be copied, so the assignement operator is declared
 *  private.
 *
 *  \param ep Unused.
 *
 *  \return *this
 */
EventPublisher& EventPublisher::operator=(const EventPublisher& ep)
{
  (void)ep;
  assert(false);
  return (*this);
}

/**************************************
*                                     *
*            Public Methods           *
*                                     *
**************************************/

/**
 *  This function will be called on termination to free ressources used by the
 *  EventPublisher.
 */
static void delete_eventpublisher()
{
  assert(EventPublisher::GetInstance());
  delete (EventPublisher::GetInstance());
  return ;
}

/**
 *  \brief EventPublisher destructor.
 *
 *  Free all internal ressources.
 */
EventPublisher::~EventPublisher()
{
  EventPublisher::instancem_.lock();
  EventPublisher::instance_ = NULL;
  EventPublisher::instancem_.unlock();
}

/**
 *  \brief Retrieve the instance of EventPublisher.
 *
 *  On the first call of this method, the EventPublisher object will be
 *  instantiated. On following calls, this object will be returned.
 *
 *  \return The EventPublisher instance.
 */
EventPublisher* EventPublisher::GetInstance()
{
  if (!EventPublisher::instance_)
    {
      EventPublisher::instancem_.lock();
      if (!EventPublisher::instance_)
	{
	  try
	    {
	      EventPublisher::instance_ = new (EventPublisher);
	    }
	  catch (...) // Do not leave the mutex locked.
	    {
	      EventPublisher::instancem_.unlock();
	      throw ;
	    }
	  atexit(delete_eventpublisher);
	  EventPublisher::instancem_.unlock();
	}
    }
  return (EventPublisher::instance_);
}

/**
 *  \brief Sends an event to all subscribers.
 *
 *  The given event has been generated and should be broadcasted to all
 *  registered EventSubscribers.
 *
 *  \param ev Event to broadcast.
 */
void EventPublisher::Publish(Events::Event* ev)
{
  std::list<EventSubscriber*>::iterator it;
  boost::unique_lock<boost::mutex> lock(this->subscribersm_);

  for (it = this->subscribers_.begin(); it != this->subscribers_.end(); it++)
    ev->AddReader(*it);
  for (it = this->subscribers_.begin(); it != this->subscribers_.end(); it++)
    (*it)->OnEvent(ev);
  return ;
}

/**
 *  \brief Subscribe to the EventPublisher.
 *
 *  When an event is generated and Publish()'ed against the EventPublisher,
 *  all objects that registered through this method will be notified through
 *  their overriden OnEvent() method.
 *
 *  \param es Object to notify on event broadcast.
 */
void EventPublisher::Subscribe(EventSubscriber* es)
{
  boost::unique_lock<boost::mutex> lock(this->subscribersm_);

  this->subscribers_.push_front(es);
  return ;
}

/**
 *  \brief Unsubscribe an object.
 *
 *  If an EventSubscriber object does not want to receive events anymore, it
 *  has to unregister itself via this method.
 *
 *  \param es Object that shouldn't receive events anymore.
 */
void EventPublisher::Unsubscribe(EventSubscriber* es)
{
  boost::unique_lock<boost::mutex> lock(this->subscribersm_);

  this->subscribers_.remove(es);
  return ;
}
