@login_required
def join_team(request):
    eid = request.REQUEST['event_id']
    e = Event.objects.get(id=eid)
    if request.method == 'POST':
        t = Team(event=e)
        t.captain = request.user
        t.chapter = request.user.profile.chapter
        t.save()
        t.members.add(request.user)
        message(request, 'New team created.')
        log(request, 'team_create', '%s created a new <a href="/teams/%d">%s team</a>.' % (name(request.user), t.id, e.name))
        return HttpResponseRedirect('/teams/%d' % t.id)
    return render_template('join_team.mako',request, teams=Team.objects.filter(event=e), event=e)

@login_required
def view_team(request, tid):
    return render_template('view_team.mako',request, team=Team.objects.get(id=tid))

@login_required
def update_team(request, tid):
    action = request.REQUEST['action']
    team = Team.objects.get(id=tid)
    
    redirect =  HttpResponseRedirect('/teams/%d/' % team.id)       
    
    if action == 'join':
        if team.entry_locked:
            return HttpResponse('Error: Team is locked; nobody may join')
        team.members.add(request.user)
        team.save()
        message(request, 'You have joined this team.')
        log(request, 'team_join', '%s joined a %s.' % (name(request.user), team.link()))
        return redirect
        
    if action == 'remove_member' and int(request.REQUEST['user_id']) == request.user.id:
        # The logged in user is leaving the team
        team.members.remove(request.user)
        message(request, 'You have left the team.')
        log(request, 'team_leave', '%s left their %s.' % (name(request.user), team.link()))
        if team.members.count() == 0:
            event = team.event.name
            team.delete()
            message(request, 'The team has been deleted because you were the last member.')
            log(request, 'team_delete', 'A %s team has been deleted.' % event)
        elif request.user == team.captain:
            team.captain = team.members.all()[0]
            team.save()
            message(request, '%s %s is the new team captain.' % (team.captain.first_name, team.captain.last_name))
            log(request, 'team_promote', '%s has been promoted to captain of %s.' % (name(team.captain), team.link()), affected=team.captain)
        return HttpResponseRedirect('/')
        
    if action == 'delete_post':
        post = TeamPost.objects.get(id=int(request.REQUEST['id']))
        if request.user == post.author or request.user == team.captain or request.user.is_superuser:
            post.delete()
            message(request, 'The post has been deleted.')
            log(request, 'team_post_delete', '%s deleted a post in a %s.' % (name(request.user), team.link()))
        else:
            message(request, 'Error: you do not have permission to delete the post.')
        return redirect
            
    if action == 'Post':
        text = request.REQUEST['message']
        post = TeamPost(team=team, author=request.user, text=text)
        post.save()
        for member in team.members.all():
            if member.id == request.user.id:
                continue
            if member.profile.posts_email == 2:
                t = get_template('email/posts_email.mako')
                body = t.render(name=member.first_name, poster=request.user.first_name, team=team, text=text, login_url=login_url(member))
                send_mail('%s Post' % team.event.name, body, 'State High TSA <scahs-tsa@pindi.us>', [member.email])
        message(request, 'Message posted.')
        log(request, 'team_post', '%s posted to their %s' % (name(request.user), team.link()))
        return redirect

    if request.user not in team.members.all() and not request.user.is_superuser:
        message(request, 'Error: you are not in this team.')
        return redirect
    # All actions beyond this point require team membership
        
    if action == 'Add Member':
        u = User.objects.get(id=int(request.REQUEST['user_id']))
        if u.teams.filter(event=team.event).count() != 0:
            message(request, 'Error: %s is already in a team for that event.' % u.first_name)
            return redirect
        team.members.add(u)
        team.save()
        message(request, '%s %s has been added to the team.' % (u.first_name, u.last_name))
        log(request, 'team_join', '%s has been added to a %s.' % (name(u), team.link()), affected=u)
        return redirect
        
    if request.user != team.captain and not request.user.is_superuser:
        message(request, 'Error: you are not the team captain.')
        return redirect
    # All actions beyond this point require team captain
    
    if action == 'lock_team':
        team.entry_locked = not team.entry_locked
        team.save()
        if team.entry_locked:
            message(request, 'The team is now locked.')
        else:
            message(request, 'The team is now unlocked.')
    if action == 'remove_member':
        u = User.objects.get(id=int(request.REQUEST['user_id']))
        team.members.remove(u)
        team.save()
        message(request, '%s %s has been removed from the team.' % (u.first_name, u.last_name))
        log(request, 'team_remove', '%s has been removed from their %s.' % (name(u), team.link()), affected=u)
    if action == 'promote_member':
        u = User.objects.get(id=int(request.REQUEST['user_id']))
        team.captain = u
        team.save()
        message(request, '%s %s has been promoted to team captain.' % (u.first_name, u.last_name))
        log(request, 'team_promote', '%s has been promoted to captain of their %s.' % (name(u), team.link()), affected=u)
    if action == 'delete_team':
        event = team.event.name
        team.delete()
        message(request, 'The team has been deleted.')
        log(request, 'team_delete', 'A %s team has been deleted.' % event)
        return HttpResponseRedirect('/')

    return redirect

