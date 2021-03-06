
@login_required
def event_list(request):
    if request.method == 'POST':
        i = 0
        locked = request.chapter.locked_events
        for event in Event.objects.all():
            if event in locked.all() and not 'lock_%d' % event.id in request.POST:
                locked.remove(event)
                i += 1
            elif not event in locked.all() and 'lock_%d' % event.id in request.POST:
                locked.add(event)
                i += 1
        message(request, '%d events updated.' % i)
        if i > 0:
            log(request, 'admin_lock', '%s updated the lock status of %d events.' % (name(request.user), i))
    return render_template('event_list.mako',request,events=request.chapter.get_events())

@login_required
def member_list(request, eid=None):
    if 'event' in request.REQUEST:
        return HttpResponseRedirect('/member_list/%s/' % request.REQUEST['event'])
    if request.method == 'POST':
        if not request.user.profile.is_admin:
            message(request, 'Error: you are not an administrator!')
            return HttpResponseRedirect('/member_list')
        action = request.POST['action']
        if request.POST.get('eid','') != "-1":
            e = Event.objects.get(id=int(request.POST['eid']))
            if e.is_team:
                t = Team(event=e, chapter=request.chapter)
                new_members = []
        else:
            e = None
        for key, val in request.POST.items():
            if key.startswith('id_'):
                # For each id field, check to see if the id has changed, and save if it has
                trash, id = key.split('_')
                try:
                    u = User.objects.get(id=int(id))
                except User.DoesNotExist:
                    continue
                if u.profile.indi_id != val:
                    u.profile.indi_id = val
                    u.profile.save()
            if key.startswith('edit_'):
                # For user checkboxes, perform the action selected on the selected users
                trash, id = key.split('_')
                u = User.objects.get(id=int(id))
                if action == 'promote':
                    u.profile.is_admin = True
                    u.profile.is_member = True
                    u.profile.save()
                    message(request, '%s promoted to administrator.' % name(u))
                    log(request, 'user_edit', '%s promoted %s to an administrator.' % (name(request.user), name(u)), u)
                elif action == 'demote':
                    if u == request.user:
                        message(request, 'Error: you cannot demote yourself.')
                        return HttpResponseRedirect('/member_list')
                    u.profile.is_admin = False
                    u.profile.is_member = True
                    u.profile.save()
                    message(request, '%s changed to normal member.' % name(u))
                    log(request, 'user_edit', '%s changed %s to a regular member.' % (name(request.user), name(u)), u)
                elif action == 'advisor':
                    u.profile.is_admin = True
                    u.profile.is_member = False
                    u.profile.save()
                    message(request, '%s changed to advisor.' % name(u))
                    log(request, 'user_edit', '%s changed %s to an advisor.' % (name(request.user), name(u)), u)
                elif action == 'delete':
                    if u == request.user:
                        message(request, 'Error: you cannot delete yourself.')
                        return HttpResponseRedirect('/member_list')
                    message(request, '%s deleted.' % name(u))
                    log(request, 'user_delete', "%s deleted %s's account." % (name(request.user), name(u)))
                    for team in Team.objects.filter(captain=u):
                        team.members.remove(u)
                        if team.members.count():
                            team.captain = team.members.all()[0]
                            message(request, '%s is the new team captain of %s\'s %s team.' % (name(team.captain), name(u), team.event.name))
                            team.save()
                        else:
                            team.delete()
                            message(request, '%s\'s %s team was dissolved.' % (name(u), team.event.name))
                    u.delete()
                elif request.POST.get('eid','') != "-1":
                    #u = User.objects.get(id=int(request.GET['uid']))
                    #e = Event.objects.get(id=int(request.POST['eid']))
                    if e.is_team:
                        new_members.append(u)
                        message(request, '%s was added to the new team.' % name(u))
                    else:
                        u.events.add(e)
                        message(request, '%s has been added to %s\'s events.' % (e.name, name(u)))
                        log(request, 'event_add', '%s added %s to %s\'s events.' % (name(request.user), e.name, name(u)), affected=u) 
                else:
                    pass
        if e and e.is_team == True and new_members:
            t.captain = new_members[0]
            message(request, 'A new %s team was created.' % e.name)
            message(request, '%s was selected to be the team captain.' % name(t.captain))
            t.save()
            for member in new_members:
                t.members.add(member)
    if request.GET.get('action') and request.user.profile.is_admin:
        action = request.GET.get('action')
        if action == 'remove_event':
            u = User.objects.get(id=int(request.GET['uid']))
            e = Event.objects.get(id=int(request.GET['eid']))
            u.events.remove(e)
            message(request, '%s has been removed from %s\'s events.' % (e.name, name(u)))
            log(request, 'event_remove', '%s removed %s from %s\'s events.' % (name(request.user), e.name, name(u)), affected=u)           
    if eid is not None:
        e = Event.objects.get(id=eid)
        members = e.entrants
    else:
        members = User.objects.all()
    members = members.filter(profile__chapter=request.chapter)
    members = members.order_by('-profile__is_member', '-profile__is_admin', 'last_name')
    if 'checklist' in request.REQUEST:
        return render_template('chapadmin/member_checklist.mako', request, members=members)
    return render_template('member_list.mako',request,
                           members=members,
                           selected_event = eid,
                           events=request.chapter.get_events(),
                           )
    
@login_required
def team_list(request, eid=None):
    if 'event' in request.REQUEST:
        return HttpResponseRedirect('/team_list/%s/' % request.REQUEST['event'])
    if request.method == 'POST':
        i = 0
        for key, value in request.POST.items():
            if not key.endswith('_id'):
                continue
            id, trash = key.split('_')
            t = Team.objects.get(id=int(id))
            if (t.team_id or value) and t.team_id != value:
                t.team_id = value
                t.save()
                i += 1
        if i != 0:
            message(request, '%d team IDs updated.' % i)
            log(request, 'edit_team_ids', '%s updated %d team IDs.' % (name(request.user), i))
            
    if eid is not None:
        teams = Team.objects.filter(event__id=eid)
    else:
        teams = Team.objects.all().order_by('event')
    teams = teams.filter(chapter=request.chapter)
    return render_template('team_list.mako',request,
                           teams=teams,
                           selected_event = eid,
                           events=request.chapter.get_events().filter(is_team=True),
                           )