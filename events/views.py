# Django imports
from django.http import HttpResponse, Http404, HttpResponseRedirect
from django.shortcuts import render_to_response, get_object_or_404
from django.db.models import Q
from django.db import transaction
from django.contrib.auth import login
from django.contrib.auth.models import User
from django.contrib.auth.decorators import login_required, user_passes_test
from django.db import connection
from django import forms
from django.core.mail import send_mail
from django.utils.html import escape

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

# Define decorators

chapter_admin_required = user_passes_test(lambda u: u.is_authenticated() and u.profile.is_admin)
system_admin_required = user_passes_test(lambda u: u.is_authenticated() and u.is_superuser)


def get_template(name):
    mylookup = TemplateLookup(directories=[TEMPLATE_DIR])
    return mylookup.get_template(name)

def render_template(name,request,**kwds):
    if 'ENABLE_ADMIN' in request.GET and request.user.is_superuser:
        request.session['DISABLE_ADMIN'] = False
    '''if 'ENABLE_ADMIN' in request.GET and request.session.get('ADMIN_ID'):
        user = User.objects.get(id=int(request.session.get('ADMIN_ID')))
        user.backend = 'django.contrib.auth.backends.ModelBackend'
        login(request, user)
        return HttpResponseRedirect('/')'''
    if 'DISABLE_ADMIN' in request.GET or request.session.get('DISABLE_ADMIN'):
        request.user.is_superuser = False
        request.user.admin_disabled = True
        request.session['DISABLE_ADMIN'] = True
    try:
        kwds.update(dict(
            user=request.user,
            chapter=request.user.profile.chapter,
            messages=request.user.get_and_delete_messages(),
            MODE = tsa.settings.MODE,
            DEPLOYED = DEPLOYED
        ))
        t = get_template(name)
        txt = t.render(**kwds)
    except:
        return HttpResponse(exceptions.html_error_template().render() )
    return HttpResponse(txt)
    
def message(request, msg):
    request.user.message_set.create(message=msg)

def log(request, type, text, affected=None):
    SystemLog(user=request.user, type=type, text=text, affected=(affected or request.user)).save()

def name(user):
    return '%s %s' % (user.first_name, user.last_name)

def login_url(user):
    return '/quick_login?user=%s&auth=%s' % (user.id, user.password.split('$')[2])
    
def generate_password():
    c, v = 'bcdfghjklmnpqrstvwxz', 'aeiou'
    r = random.choice
    return r(c) + r(v) + r(c) + r(v) + r(c) + str(random.randint(100,999))
    



@login_required
def index(request):
    if not request.chapter:
        return HttpResponseRedirect('/config/chapter_list')
    for user in User.objects.all():
        try:
            user.profile
        except UserProfile.DoesNotExist:
            UserProfile(user=user, is_member=True, chapter=None).save()
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
            if e.is_locked(request.user):
                message(request, 'Error: Event is locked')
            elif request.user in e.entrants.all():
                message(request, 'Error: You are already in that event.')
            else:
                e.entrants.add(request.user)
                message(request, 'Individual event "%s" added.' % e.name)
                log(request, 'event_add', '%s added the individual event %s.' % (name(request.user), e.name))
    if 'delete_event' in request.GET:
        eid = int(request.GET['delete_event'])
        e = Event.objects.get(id=eid)
        e.entrants.remove(request.user)
        message(request, 'Individual event "%s" removed.' % e.name)
        log(request, 'event_remove', '%s removed the individual event %s.' % (name(request.user), e.name))
    return index(request)

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
    if request.GET.get('event'):
        e = Event.objects.get(id=request.GET['event'])
        members = e.entrants
    else:
        members = User.objects.all()
    members = members.filter(profile__chapter=request.chapter, profile__is_member=True)
    return render_template('member_list.mako',request,
                           members=members,
                           selected_event = request.GET.get('event'),
                           events=Event.objects.filter(is_team=False),
                           form=form)
    
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
                           events=Event.objects.filter(is_team=True),
                           )
@login_required 
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
            u = request.user
            u.first_name = escape(request.POST['first_name'])
            u.last_name = escape(request.POST['last_name'])
            u.email = request.POST['email']
            if request.POST['new_password'] and not u.check_password(request.POST['old_password']):
                message(request, 'Error: Old password is not correct.')
            elif request.POST['new_password'] != request.POST['confirm_password']:
                message(request, 'Error: Password do not match.')
            elif request.POST['new_password']:
                u.set_password(request.POST['new_password'])
                message(request, 'Your password has been changed.')
                log(request, 'password_change', '%s changed their password.' % (name(request.user)))
            u.save()
            message(request, 'Your settings have been updated.')
    return render_template('settings.mako',request, url=login_url(request.user))

def create_account(request):
    email = request.POST['email']
    if '@' not in email:
        return HttpResponse('Error: Email is invalid.')
    username, domain = email.split('@')
    if domain != 'scasd.org':
        return HttpResponse('Error: Email must be @scasd.org')
    first_name = escape(request.POST['first_name'])
    last_name = escape(request.POST['last_name'])
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
        
    SystemLog(user=u, affected=u, type='new_user', text='New user %s registered.' % name(u)).save()
        
    return HttpResponse('Your account has been created. Check your email for login details.')
    
execfile(paths(APP_DIR, 'views_team.py'))
execfile(paths(APP_DIR, 'views_admin.py'))
