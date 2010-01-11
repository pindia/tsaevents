
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
def member_list(request):
    if request.method == 'POST':
        if not request.user.profile.is_admin:
            message(request, 'Error: you are not an administrator!')
            return HttpResponseRedirect('/member_list')
        action = request.POST['action']
        for key in request.POST:
            if key.startswith('edit_'):
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
                    u.delete()
                elif request.POST.get('action_button','') == 'Add Event':
                    #u = User.objects.get(id=int(request.GET['uid']))
                    e = Event.objects.get(id=int(request.POST['eid']))
                    u.events.add(e)
                    message(request, '%s has been added to %s\'s events.' % (e.name, name(u)))
                    log(request, 'event_add', '%s added %s to %s\'s events.' % (name(request.user), e.name, name(u)), affected=u) 
                else:
                    pass
    if request.GET.get('action') and request.user.profile.is_admin:
        action = request.GET.get('action')
        if action == 'remove_event':
            u = User.objects.get(id=int(request.GET['uid']))
            e = Event.objects.get(id=int(request.GET['eid']))
            u.events.remove(e)
            message(request, '%s has been removed from %s\'s events.' % (e.name, name(u)))
            log(request, 'event_remove', '%s removed %s from %s\'s events.' % (name(request.user), e.name, name(u)), affected=u)           
    if request.GET.get('event'):
        e = Event.objects.get(id=request.GET['event'])
        members = e.entrants
    else:
        members = User.objects.all()
    members = members.filter(profile__chapter=request.chapter, is_superuser=False)
    members = members.order_by('-profile__is_member', '-profile__is_admin', 'last_name')
    return render_template('member_list.mako',request,
                           members=members,
                           selected_event = request.GET.get('event'),
                           events=request.chapter.get_events().filter(is_team=False),
                           )
    
@login_required
def team_list(request):
    if request.GET.get('event'):
        teams = Team.objects.filter(event__id=int(request.GET['event']))
    else:
        teams = Team.objects.all().order_by('event')
    teams = teams.filter(chapter=request.chapter)
    return render_template('team_list.mako',request,
                           teams=teams,
                           selected_event = request.GET.get('event'),
                           events=request.chapter.get_events().filter(is_team=True),
                           )