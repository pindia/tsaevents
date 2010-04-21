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
            'fields': ('is_team', 'team_size', 'max_region', 'max_state', 'max_nation')
        }),
        ('Entrants', {
            'description' : 'Only use for individual events!',
            'fields': ('entrants',)
        }),
     )
     filter_horizontal = ('entrants',)
     list_display = ('name','short_name','is_team','min_team_size','team_size','render_region','render_state','render_nation')
     list_editable = ('short_name','min_team_size','team_size')
     list_filter = ('is_team','event_set')
     ordering=('id',)
     #actions=[lock_events]

class TeamAdmin(admin.ModelAdmin):
     list_display = ('event','members_list','team_id')
     list_filter = ('event',)
     filter_horizontal = ('members',)

class ProfileInline(admin.TabularInline):
     model = UserProfile
     
class ProfileAdmin(admin.ModelAdmin):
     list_display = ('name', 'is_member', 'chapter', 'indi_id')
     list_editable = ('is_member','chapter','indi_id')
     list_filter = ('is_member','chapter')

admin.site._registry[User].inlines = (ProfileInline,)


admin.site.register(Event, EventAdmin)
admin.site.register(Team, TeamAdmin)
admin.site.register(UserProfile, ProfileAdmin)
admin.site.register(Chapter)
admin.site.register(EventSet)