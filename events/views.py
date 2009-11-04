# Django imports
from django.http import HttpResponse, Http404, HttpResponseRedirect
from django.shortcuts import render_to_response, get_object_or_404
from django.db.models import Q
from django.db import transaction
from django.contrib.auth import login
from django.contrib.auth.models import User
from django.contrib.auth.decorators import login_required
from django.db import connection
from django import forms
from django.core.mail import send_mail

# Mako imports
from mako.template import Template
from mako import exceptions
from mako.lookup import TemplateLookup

# Standard library imports
import time, datetime, os, timeit, string, random
from itertools import *

# Project-specific imports
from models import *
from tsa.config import *
import tsa.settings

def get_template(name):
    mylookup = TemplateLookup(directories=[TEMPLATE_DIR])
    return mylookup.get_template(name)

def render_template(name,request,**kwds):
    try:
        kwds.update(dict(
            user=request.user,
            messages=request.user.get_and_delete_messages(),
            MODE = tsa.settings.MODE
        ))
        t = get_template(name)
        txt = t.render(**kwds)
    except:
        return HttpResponse(exceptions.html_error_template().render() )
    return HttpResponse(txt)
    
def message(request, msg):
    request.user.message_set.create(message=msg)

def login_url(user):
    return '/quick_login?user=%s&auth=%s' % (user.id, user.password.split('$')[2])
    
def generate_password():
    c, v = 'bcdfghjklmnpqrstvwxz', 'aeiou'
    r = random.choice
    return r(c) + r(v) + r(c) + r(v) + r(c) + str(random.randint(100,999))
    



@login_required
def index(request):
    for user in User.objects.all():
        try:
            user.profile
        except UserProfile.DoesNotExist:
            UserProfile(user=user, is_member=True, senior=False).save()
    return render_template('index.mako',request, events=Event.objects.all())

def quick_login(request):
    user = User.objects.get(id=int(request.GET['user']))
    if user.is_superuser and DEPLOYED:
        return HttpResponse('Error: Admins cannot login using the quick links for security reasons.')
    if user.password.split('$')[2] == request.GET['auth']:
        user.backend = 'django.contrib.auth.backends.ModelBackend'
        login(request, user)
        return HttpResponseRedirect(request.GET.get('next','/'))
    else:
        return HttpResponse('Error: Authentication token is invalid. Either you\'re trying to login as someone else using your authentication token (nice try), or your password has been reset since this link was generated.')

@login_required
def update_indi(request):
    if request.method == 'POST':
        eid = int(request.POST['add_indi_event'])
        if eid != -1:
            e = Event.objects.get(id=eid)
            if e.entry_locked:
                message(request, 'Error: Event is locked')
            elif request.user in e.entrants.all():
                message(request, 'Error: You are already in that event.')
            else:
                e.entrants.add(request.user)
                message(request, 'Individual event "%s" added.' % e.name)
    if 'delete_event' in request.GET:
        eid = int(request.GET['delete_event'])
        e = Event.objects.get(id=eid)
        e.entrants.remove(request.user)
        message(request, 'Individual event "%s" removed.' % e.name)
    return index(request)

@login_required
def join_team(request):
    eid = request.REQUEST['event_id']
    e = Event.objects.get(id=eid)
    if request.method == 'POST':
        t = Team(event=e)
        t.captain = request.user
        t.senior = request.user.profile.senior
        t.save()
        t.members.add(request.user)
        message(request, 'New team created.')
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
        return redirect
        
    if action == 'remove_member' and int(request.REQUEST['user_id']) == request.user.id:
        # The logged in user is leaving the team
        team.members.remove(request.user)
        message(request, 'You have left the team.')
        if team.members.count() == 0:
            team.delete()
            message(request, 'The team has been deleted because you were the last member.')
        elif request.user == team.captain:
            team.captain = team.members.all()[0]
            team.save()
            message(request, '%s %s is the new team captain.' % (team.captain.first_name, team.captain.last_name))
        return HttpResponseRedirect('/')
        
    if action == 'delete_post':
        post = TeamPost.objects.get(id=int(request.REQUEST['id']))
        if request.user == post.author or request.user == team.captain or request.user.is_superuser:
            post.delete()
            message(request, 'The post has been deleted.')
        else:
            message(request, 'Error: you do not have permission to delete the post.')
        return redirect
        
    if request.user not in team.members.all() and not request.user.is_superuser:
        message(request, 'Error: you are not in this team.')
        return redirect
    # All actions beyond this point require team membership
    
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
        return redirect
        
    if action == 'Add Member':
        u = User.objects.get(id=int(request.REQUEST['user_id']))
        if u.teams.filter(event=team.event).count() != 0:
            message(request, 'Error: %s is already in a team for that event.' % u.first_name)
            return redirect
        team.members.add(u)
        team.save()
        message(request, '%s %s has been added to the team.' % (u.first_name, u.last_name))
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
    if action == 'promote_member':
        u = User.objects.get(id=int(request.REQUEST['user_id']))
        team.captain = u
        team.save()
        message(request, '%s %s has been promoted to team captain.' % (u.first_name, u.last_name))
    if action == 'delete_team':
        team.delete()
        return HttpResponseRedirect('/')
        message(request, 'The team has been deleted.')

    return redirect

@login_required
def event_list(request):
    if request.method == 'POST':
        i = 0
        for event in Event.objects.all():
            if event.entry_locked and not 'lock_%d' % event.id in request.POST:
                event.entry_locked = False
                event.save()
                i += 1
            elif not event.entry_locked and 'lock_%d' % event.id in request.POST:
                event.entry_locked = True
                event.save()
                i += 1
        message(request, '%d events updated.' % i)
    return render_template('event_list.mako',request,events=Event.objects.all())
    
class NewUserForm(forms.Form):
        username = forms.CharField()
        first_name = forms.CharField()
        last_name = forms.CharField()
        email = forms.EmailField()
        chapter = forms.ChoiceField(choices=[('under','9/10'),('senior','11/12'),('none','None')])
    

@login_required
def member_list(request):
    if request.method == 'POST':
        form = NewUserForm(request.POST)
        if form.is_valid():
            d = form.cleaned_data
            password = generate_password()
            user = User(username=d['username'], first_name=d['first_name'], last_name=d['last_name'], email=d['email'])
            user.set_password(password)
            user.save()
            profile = UserProfile(is_member = (d['chapter'] != 'none'), senior = (d['chapter'] == 'senior'), user=user)
            profile.save()
            message(request, 'New user "%s" created. Generated password: "%s"' % (d['username'], password))
            form = NewUserForm()
    else:
        form = NewUserForm()
    return render_template('member_list.mako',request,members=User.objects.all(),form=form)
    
@login_required
def team_list(request):
    return render_template('team_list.mako',request,teams=Team.objects.all())
    
def settings(request):
    if request.method == 'POST':
        if request.POST['action'] == 'Regenerate Password':
            password = generate_password()
            u = request.user
            u.set_password(password)
            u.save()
            url = login_url(u)
            body = get_template('email/reset_password.mako').render(name=u.first_name, username=u.username, password=password, login_url=url)
            send_mail('TSA Event Registration Login', body, 'State High TSA <scahs-tsa@pindi.us>', [u.email])
            message(request, 'Your password has been reset. Check your email for your new information.')
        else:
            p = request.user.profile
            print request.POST
            if 'posts_email' in request.POST:
                p.posts_email = 2
            else:
                p.posts_email = 0
            p.save()
            message(request, 'Your settings have been updated.')
    return render_template('settings.mako',request, url=login_url(request.user))

def create_account(request):
    email = request.POST['email']
    if '@' not in email:
        return HttpResponse('Error: Email is invalid.')
    username, domain = email.split('@')
    if domain != 'scasd.org':
        return HttpResponse('Error: Email must be @scasd.org')
    first_name = request.POST['first_name']
    last_name = request.POST['last_name']
    chapter = request.POST['chapter']
    password = generate_password()

    u = User(username=username, first_name=first_name, last_name=last_name, email=email)
    u.set_password(password)
    u.save()
    profile = UserProfile(is_member=True, senior= (chapter == '1112'), user=u)
    profile.save()

    url = login_url(u)
    
    t = get_template('email/newuser.mako')
    body = t.render(name=first_name, username=username, password=password, login_url=url)
    

    send_mail('TSA Event Registration Login', body, 'State High TSA <scahs-tsa@pindi.us>', [email])
    
    return HttpResponse('Your account has been created. Check your email for login details.')