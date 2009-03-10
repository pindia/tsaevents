from django.contrib import admin
from models import *

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
            'fields': ('entrants',)
        }),
     )
     filter_horizontal = ('entrants',)
     list_display = ('name','is_team','team_size','max_region','max_state','max_nation','entry_locked')
     list_filter = ('is_team', 'entry_locked')

class TeamAdmin(admin.ModelAdmin):
     list_display = ('event','team_id')
     list_filter = ('event',)
     filter_horizontal = ('members',)


admin.site.register(Event, EventAdmin)
admin.site.register(Team, TeamAdmin)