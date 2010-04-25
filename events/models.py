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
    
    short_name = models.CharField(max_length=50, blank=True)
    chapter_id = models.CharField(max_length=20, blank=True)
    all_locked = models.BooleanField()
    
    message = models.TextField(blank=True)
    info = models.TextField(blank=True, db_column='extra_text1')
    
    #mode = models.IntegerField(choices=((0,'region'), (1,'state'), (2,'nation')), default=0)
    
    key = models.CharField(max_length=100, default='', blank=True, db_column='extra_char1')
    
    # Link to another chapter. The "child" chapter has a link to the parent and not vice versa
    #link = models.ForeignKey('Chapter', db_column='extra_int1', null=True, blank=True) 
    
    #extra_char1 = models.CharField(max_length=100, default='', blank=True)
    extra_char2 = models.CharField(max_length=100, default='', blank=True)
    extra_char3 = models.CharField(max_length=100, default='', blank=True)
    extra_bool1 = models.BooleanField(default=False, blank=True)
    extra_bool2 = models.BooleanField(default=False, blank=True)
    extra_bool3 = models.BooleanField(default=False, blank=True)
    #extra_int1 = models.IntegerField(default=0)
    #extra_int2 = models.IntegerField(default=0)
    #extra_text1 = models.TextField(blank=True)
    
    @property
    def link(self):
        if self.name == 'State High 9/10':
            return Chapter.objects.get(name='State High 11/12')
        else:
            return None
    @property
    def reverselink(self):
        if self.name == 'State High 11/12':
            return Chapter.objects.get(name='State High 9/10')
        else:
            return None
        
        
    def get_events(self):
        return self.event_set.events.all()
    def get_fields(self, category=None):
        if self.link:
            f = self.link.fields.all()
        else:
            f = self.fields.all()
        if category:
            f = f.filter(category=category)
        return f.order_by('category','weight')
    def __str__(self):
        return self.name

class Announcement(models.Model):
    chapter = models.ForeignKey(Chapter, related_name='announcements')
    author = models.ForeignKey(User)
    create_date = models.DateTimeField(auto_now_add=True)
    update_date = models.DateTimeField(auto_now=True)
    title = models.CharField(max_length=100, default='')
    text = models.TextField()
    active = models.BooleanField(default=True)
    
    extra_char1 = models.CharField(max_length=100, default='')
    extra_int1 = models.IntegerField(default=0)
    extra_bool1 = models.BooleanField(default=False)
    
    def render_text(self):
        t = self.text
        t = t.replace('<','&lt;')
        t = t.replace('>','&gt;')
        t = t.replace('"','&quot;')
        t = t.replace('\n', '<br>')
        return t
    
def get_upload_path(instance, filename):
    return '%d/%s' % (instance.chapter.id, filename)
    
class ChapterFile(models.Model):
    chapter = models.ForeignKey(Chapter, related_name='files')
    author = models.ForeignKey(User)
    create_date = models.DateTimeField(auto_now_add=True)
    update_date = models.DateTimeField(auto_now=True)
    name = models.CharField(max_length=100)
    
    file = models.FileField(upload_to=get_upload_path)
    size = models.IntegerField()
    active = models.BooleanField(default=True)




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
    
    def get_field(self, field):
        try:
            fv = FieldValue.objects.get(user=self.user, field=field)
        except FieldValue.DoesNotExist:
            fv = FieldValue(user=self.user, field=field, raw_value=field.default_value)
            fv.save()
        return fv.get_value(field.type)
        
    def set_field(self, field, val):
        fv = FieldValue.objects.get(user=self.user, field=field)
        fv.set_value(field.type, val)
        
    def get_id(self):
        id = self.indi_id
        if not id:
            return ''
        if '-' in id:
            return id.split('-')[-1]
        else:
            return id
        

TYPE_CHOICES = zip(range(2),['Boolean', 'Text'])
VIEW_CHOICES = zip(range(3),['Admin only', 'User or Admin', 'Everyone'])
EDIT_CHOICES = zip(range(2),['Admin only', 'User or Admin', 'Admin (logged)', 'Editing locked'])

class Field(models.Model):
    name = models.CharField(max_length=50)
    short_name = models.CharField(max_length=20)
    chapter = models.ForeignKey(Chapter, related_name='fields')
    type = models.IntegerField(default=0, choices=TYPE_CHOICES)
    view_perm = models.IntegerField(default=0, choices=VIEW_CHOICES)
    edit_perm = models.IntegerField(default=0, choices=EDIT_CHOICES)
    default_value = models.CharField(max_length=50, default='')
    category = models.CharField(max_length=20, default='Main')
    weight = models.IntegerField(default=0)
    size = models.IntegerField(default=12)
    
    def format_value(self, val):
        if self.type == 0:
            return 'Yes' if val == '1' or val == True else 'No'
        elif not val:
            return '-'
        else:
            return val
    
class FieldValue(models.Model):
    field = models.ForeignKey(Field)
    user = models.ForeignKey(User)
    raw_value = models.CharField(max_length=50, default='')
    def get_value(self, ftype):
        if ftype == 0:
            return self.raw_value == '1'
        else:
            return self.raw_value
    def set_value(self, ftype, val):
        if ftype == 0:
            self.raw_value = '1' if val else '0'
        else:
            self.raw_value = val
        self.save()

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
    chapter = models.ForeignKey(Chapter, related_name='teams')
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
        
    
    def members_list(self, sep=', '):
        return sep.join(['%s %s' % (member.first_name, member.last_name[0]) for member in self.members.all()])
    members_list.short_description='Members'
    
    def link(self):
        return '<a href="/teams/%d">%s team</a>' % (self.id, self.event.name)
        
    def get_id(self):
        val = self.team_id
        if not val:
            return ''
        if '-' in val:
            return val.split('-')[-1]
        else:
            return val
    
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
    

