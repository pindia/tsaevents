from django.db import models
from django.contrib.auth.models import User

# Create your models here.

EMAIL_CHOICES = (
    (0,'None'),
    (1,'Digest'),
    (2,'Immediate')
)

class UserProfile(models.Model):
    user = models.OneToOneField(User, related_name='profile')
    is_member = models.BooleanField()
    senior = models.BooleanField()
    indi_id = models.CharField(max_length=100, blank=True)
    
    notify_email = models.IntegerField(choices=EMAIL_CHOICES)
    posts_email = models.IntegerField(choices=EMAIL_CHOICES)
    
    def name(self):
        return '%s %s' % (self.user.first_name, self.user.last_name[0])
    name.short_description = 'Name'


class Event(models.Model):
    name = models.CharField(max_length=100)
    #short_name = models.CharField(max_length=100)

    is_team = models.BooleanField(help_text='Check if team event, leave blank if individual')
    team_size = models.IntegerField(help_text='Number of people allowed on a team')

    max_region = models.IntegerField(help_text='Number of entrants or teams allowed at Regionals')
    max_state = models.IntegerField(help_text='Number of entrants or teams allowed at States. -1 if it is a qualification required event.')
    max_nation = models.IntegerField(help_text='Number of entrants or teams allowed at States. -x if it is an x per state event. Example: -3 means 3 per state.')

    entrants = models.ManyToManyField(User, related_name='events', help_text='Do NOT add entrants if this is a team event. Create teams for the event and add members to them instead!', blank=True)
    entry_locked = models.BooleanField(default=False, help_text='Check to prevent signups for this event. Use when it is full and any conflicts between possible entrants are resolved.')
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


class Team(models.Model):
    event = models.ForeignKey(Event, related_name='teams')
    team_id = models.CharField(max_length=100, null=True, blank=True)
    senior = models.BooleanField()
    info = models.TextField(null=True, blank=True)
    
    members = models.ManyToManyField(User, related_name='teams')
    captain = models.ForeignKey(User)
    
    entry_locked = models.BooleanField(default=False)
    
    def members_list(self):
        return ', '.join(['%s %s' % (member.first_name, member.last_name[0]) for member in self.members.all()])
    members_list.short_description='Members'
    
class TeamPost(models.Model):
    team = models.ForeignKey(Team, related_name='posts')
    author = models.ForeignKey(User, related_name='posts')
    date = models.DateTimeField(auto_now_add=True)
    text = models.TextField()

