from django.contrib import admin
from django.contrib.auth.models import User
from models import *

def lock_events(modeladmin, request, queryset):
     queryset.update(entry_locked=True)
lock_events.short_description = 'Lock selected events'


class EventAdmin(admin.ModelAdmin):
     fieldsets = (
        (None, {
            'fields': ('name',)
        }),
        ('Eligibility', {
            #'classes': ('collapse',),
            'fields': ('is_team', 'team_size', 'max_region', 'max_state', 'max_nation','entry_locked')
        }),
        ('Entrants', {
            'description' : 'Only use for individual events!',
            'fields': ('entrants',)
        }),
     )
     filter_horizontal = ('entrants',)
     list_display = ('name','is_team','team_size','render_region','render_state','render_nation','entry_locked')
     list_filter = ('is_team', 'entry_locked')
     list_editable=('entry_locked',)
     ordering=('id',)
     #actions=[lock_events]

class TeamAdmin(admin.ModelAdmin):
     list_display = ('event','members_list','team_id')
     list_filter = ('event',)
     filter_horizontal = ('members',)

class ProfileInline(admin.TabularInline):
     model = UserProfile
     
class ProfileAdmin(admin.ModelAdmin):
     list_display = ('name', 'is_member', 'senior', 'indi_id')
     list_editable = ('is_member','senior','indi_id')
     list_filter = ('is_member', 'senior')

admin.site._registry[User].inlines = (ProfileInline,)


admin.site.register(Event, EventAdmin)
admin.site.register(Team, TeamAdmin)
admin.site.register(UserProfile, ProfileAdmin)