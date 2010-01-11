from django.db import models
from django.contrib.auth.models import User

# Create your models here.

EMAIL_CHOICES = (
    (0,'None'),
    (1,'Digest'),
    (2,'Immediate')
)


class Chapter(models.Model):
    name = models.CharField(max_length=100)
    event_set = models.ForeignKey('EventSet')
    locked_events = models.ManyToManyField('Event', blank=True)
    register_open = models.BooleanField(default=True)
    def get_events(self):
        return self.event_set.events.all()
    def __str__(self):
        return self.name


class UserProfile(models.Model):
    user = models.OneToOneField(User, related_name='profile')
    is_member = models.BooleanField()
    is_admin = models.BooleanField()

    chapter = models.ForeignKey(Chapter, related_name='members',null=True, blank=True)
    indi_id = models.CharField(max_length=100, blank=True)
    
    notify_email = models.IntegerField(choices=EMAIL_CHOICES, default=0)
    posts_email = models.IntegerField(choices=EMAIL_CHOICES, default=2)
    
    def name(self):
        return '%s %s' % (self.user.first_name, self.user.last_name[0])
    name.short_description = 'Name'


class EventSet(models.Model):
    #name = models.CharField(max_length=100)
    level = models.CharField(max_length=10, choices=(('MS','MS'),('HS','HS')))
    state = models.CharField(max_length=50)
    region = models.CharField(max_length=50)
    def __str__(self):
        return '%s %s %s' % (self.state, self.region, self.level)
    

class Event(models.Model):
    event_set = models.ForeignKey(EventSet, related_name='events')
    
    name = models.CharField(max_length=100)
    short_name = models.CharField(max_length=100)

    is_team = models.BooleanField(help_text='Check if team event, leave blank if individual')
    team_size = models.IntegerField(help_text='Number of people allowed on a team')
    min_team_size = models.IntegerField(default=1)

    max_region = models.IntegerField(help_text='Number of entrants or teams allowed at Regionals')
    max_state = models.IntegerField(help_text='Number of entrants or teams allowed at States. -1 if it is a qualification required event.')
    max_nation = models.IntegerField(help_text='Number of entrants or teams allowed at States. -x if it is an x per state event. Example: -3 means 3 per state.')

    entrants = models.ManyToManyField(User, related_name='events', help_text='Do NOT add entrants if this is a team event. Create teams for the event and add members to them instead!', blank=True)

    entry_locked = models.BooleanField(default=False)
    entry_locked_senior = models.BooleanField(default=False)
    
    def __str__(self):
        return self.name

    def render_region(self):
        if self.max_region == 0:
            return '-'
        if self.max_region == -1:
            return '?'
        return self.max_region
    render_region.short_description='Max region'
    def render_state(self):
        if self.max_state == -1:
            return 'Q'
        return self.max_state
    render_state.short_description='Max state'
    def render_nation(self):
        if self.max_nation == 0:
            return '-'
        if self.max_nation < 0:
            return '%d/s' % -self.max_nation
        return self.max_nation
    render_nation.short_description='Max nation'
    
    def is_locked(self, user):
        return self in user.profile.chapter.locked_events.all()


P_OPEN = 0
P_VIEW_ONLY = 1
P_MEMBERS_ONLY = 2
P_CAPTAIN_ONLY = 3

class Team(models.Model):
    event = models.ForeignKey(Event, related_name='teams')
    team_id = models.CharField(max_length=100, null=True, blank=True)
    chapter = models.ForeignKey(Chapter)
    info = models.TextField(null=True, blank=True)
    
    members = models.ManyToManyField(User, related_name='teams')
    captain = models.ForeignKey(User)
    
    entry_locked = models.BooleanField(default=False)
    
    entry_privacy = models.SmallIntegerField(default=0)
    board_privacy = models.SmallIntegerField(default=0)
    
    def can_view_board(self, user):
        return user in self.members.all() or self.board_privacy in [P_OPEN, P_VIEW_ONLY]
        
    def can_post_board(self, user):
        return user in self.members.all() or self.board_privacy == P_OPEN
        
    def can_join(self, user):
        return self.entry_privacy == P_OPEN
    
    def can_invite(self, user):
        return (user in self.members.all() and self.entry_privacy == P_OPEN) or user.profile.is_admin or \
            user == self.captain or (user in self.members.all() and self.entry_privacy == P_MEMBERS_ONLY)
        
    
    def members_list(self):
        return ', '.join(['%s %s' % (member.first_name, member.last_name[0]) for member in self.members.all()])
    members_list.short_description='Members'
    
    def link(self):
        return '<a href="/teams/%d">%s team</a>' % (self.id, self.event.name)
    
class TeamPost(models.Model):
    team = models.ForeignKey(Team, related_name='posts')
    author = models.ForeignKey(User, related_name='posts')
    date = models.DateTimeField(auto_now_add=True)
    text = models.TextField()
    
class SystemLog(models.Model):
    user = models.ForeignKey(User, related_name='log_actions')
    chapter = models.ForeignKey(Chapter, null=True, blank=True, default=None)
    affected = models.ForeignKey(User, related_name='log_entries', null=True, blank=True)
    type = models.CharField(max_length='20')
    text = models.CharField(max_length='100')
    date = models.DateTimeField(auto_now_add=True)
    read = models.BooleanField(default=False)
    is_personal = models.BooleanField(default=False)
    

