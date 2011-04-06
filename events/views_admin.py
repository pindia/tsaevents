

@chapter_admin_required
def attendance(request):
    c = request.chapter
    
    meetings = list(ChapterMeeting.objects.filter(chapter=(c.link or c)).order_by('date'))
    members = list(User.objects.filter(profile__chapter=c, profile__is_member=True).order_by('last_name'))
    if c.link:
        members += list(User.objects.filter(profile__chapter=c.link, profile__is_member=True).order_by('last_name'))
    if c.reverselink:
        members = list(User.objects.filter(profile__chapter=c.reverselink, profile__is_member=True).order_by('last_name')) + members
    attendees = {}
    for meeting in meetings:
        attendees[meeting] = list(meeting.attendees.all())
    for member in members:
        total = len(meetings)
        if total == 0:
            member.percent = 100
        else:
            num = len([meeting for meeting in meetings if member in attendees[meeting]])
            member.percent = int(num*100/total)
        
    
    
    if request.method == 'POST':
        action = request.POST['action']
        if action == 'Create':
            d = datetime.datetime.strptime(request.POST['date'],'%m/%d/%y').date()
            m = ChapterMeeting(chapter=(c.link or c), date=d)
            m.save()
        elif action == 'X':
            m = ChapterMeeting.objects.get(id=int(request.POST['meeting']))
            m.delete()
        else:
            for meeting in meetings:
                for member in members:
                    key = '%d-%d' % (meeting.id, member.id)
                    if member in attendees[meeting] and key not in request.POST:
                        meeting.attendees.remove(member)
                    if member not in attendees[meeting] and key in request.POST:
                        meeting.attendees.add(member)
        return HttpResponseRedirect('/attendance')

    return render_template('chapadmin/attendance.mako', request, members=members, meetings=meetings, attendees = attendees)


@chapter_admin_required
def member_fields(request, category):
    category = category or 'Main'
    members = User.objects.filter(profile__chapter=request.chapter, is_superuser=False, profile__is_member=True).order_by('last_name')
    fields = request.chapter.get_fields()
    categories = set(fields.values_list('category', flat=True))
    fields = fields.filter(category=category)
    if request.method == 'POST':
        if str(request.chapter.id) != request.POST.get('chapter'): # Sanity check; are we updating the right chapter?
            message(request, 'Error: Chapter was changed before form was submitted.')
        else:
            i = 0
            for member in members:
                for field in fields:
                    if field.edit_perm == 3: #Skip fields that are edit-locked
                        continue
                    key = '%d_%d' % (member.id, field.id)
                    fv = member.profile.get_field(field)
                    if field.type == 0:
                        if fv and key not in request.POST:
                            member.profile.set_field(field, False)
                            i += 1
                        if not fv and key in request.POST:
                            member.profile.set_field(field, True)
                            i += 1
                    else:
                        if fv != request.POST[key]:
                            member.profile.set_field(field, request.POST[key])
                            i += 1
            message(request, '%d fields updated.' % i)
                        
                    
    return render_template('chapadmin/member_fields.mako', request, members=members, fields=fields, categories=categories, category=category)


@chapter_admin_required
def chapter_info(request):
    c = (request.chapter.link or request.chapter)
    if request.method == 'POST':
        if request.POST.get('new_announce'):
            a = Announcement(chapter=c, author=request.user, text=request.POST['new_announce'])
            a.save()
            message(request, 'New announcement created.')
            log(request, 'announce_create', '%s posted a new announcement.' % name(request.user))
            
        if request.FILES.get('new_file'):
            uf = request.FILES['new_file']
            if uf.size > 25 * 2 ** 20:
                message(request, 'Error: Files cannot be larger than 25 MB')
                return render_template('index.mako', request)
            if c.files.count() >= 10:
                message(request, 'Error: There cannot be more than 10 files per chapter. Delete some old files and try again.')
                return render_template('index.mako', request)
            f = ChapterFile(chapter=c, author=request.user, name=uf.name, size=uf.size, file=uf)
            f.save()
            message(request, 'New file uploaded.')
            log(request, 'file_create', '%s uploaded the file "%s".' % (name(request.user), f.name))
            
        if request.POST.get('create_event'):
            try:
                d = datetime.date(month=int(request.POST['editeventmonth_create']),
                                  day=int(request.POST['editeventday_create']),
                                  year=int(request.POST['editeventyear_create']))
            except ValueError: # Date was not valid
                message(request, 'Error: Date is not valid')
                return render_template('index.mako', request)
            if d < datetime.date.today():
                message(request, 'Error: Date is before today')
                return render_template('index.mako', request)
            e = CalendarEvent(chapter=c, author=request.user, name=request.POST['editeventname_create'], date=d)
            e.save()
            message(request, 'New event created.')
            
        for key, value in request.POST.items():
            if key.startswith('editannounce_'):
                junk, aid = key.split('_')
                if 'deleteannounce_%s' % aid in request.POST:
                    continue
                a = Announcement.objects.get(id=int(aid))
                if a.text != value:
                    a.text = value
                    a.save()
                    message(request, 'Announcement updated.')
            if key.startswith('deleteannounce_'):
                junk, aid = key.split('_')
                a = Announcement.objects.get(id=(int(aid)))
                log(request, 'announce_delete', '%s deleted an announcement.' % name(request.user))
                message(request, 'Announcement deleted.')
                a.delete()
                
            if key.startswith('editfile_'):
                junk, fid = key.split('_')
                if 'deletefile_%s' % fid in request.POST:
                    continue
                f = ChapterFile.objects.get(id=int(fid))
                if f.name != value:
                    f.name = value
                    f.save()
                    message(request, 'File updated.')
            if key.startswith('deletefile_'):
                junk, fid = key.split('_')
                f = ChapterFile.objects.get(id=(int(fid)))
                message(request, 'File deleted.')
                log(request, 'file_delete', '%s deleted the file "%s".' % (name(request.user), f.name))
                f.delete()
                
        for event in c.calendar_events.all():
            if 'editeventname_%d' % event.id not in request.POST:
                continue
            if 'deleteevent_%d' % event.id in request.POST:
                event.delete()
                message(request, 'Event deleted.')
                continue
            n = request.POST['editeventname_%d' % event.id]
            m = int(request.POST['editeventmonth_%d' % event.id])
            d = int(request.POST['editeventday_%d' % event.id])
            y = int(request.POST['editeventyear_%d' % event.id])
            if n != event.name or m != event.date.month or d != event.date.day or y != event.date.year:
                event.name = n
                event.date = datetime.date(month=m, day=d, year=y)
                if(event.date < datetime.date.today()):
                    message(request, 'Error: Date is before today')
                    return render_template('index.mako', request)
                event.save()
                message(request, 'Event updated.')
                
    #return render_template('chapadmin/chapter_info.mako', request)
    return render_template('index.mako', request)


@chapter_admin_required
def edit_chapter(request):
    c = request.chapter
    if request.method == 'POST':
        c.register_open = 'register_open' in request.POST
        c.info = request.POST['info']
        c.key = request.POST['key']
        c.chapter_id=request.POST['chapter_id']
        c.save()
        message(request, 'Chapter settings updated.')
        if not c.link: # Only edit fields if no master chapter
            for field in c.get_fields():
                name = request.POST['%d_name' % field.id]
                short_name = request.POST['%d_short_name' % field.id]
                category = request.POST['%d_category' % field.id]
                weight = int(request.POST['%d_weight' % field.id])
                view_perm = int(request.POST['%d_view_perm' % field.id])
                edit_perm = int(request.POST['%d_edit_perm' % field.id])
                if name == 'DELETE':
                    field.delete()
                    continue
                if field.name != name or field.category != category or field.weight != weight or field.short_name != short_name or field.view_perm != view_perm or field.edit_perm != edit_perm:
                    field.name = name
                    field.short_name = short_name
                    field.category = category
                    field.weight = weight
                    field.edit_perm = edit_perm
                    field.view_perm = view_perm
                    field.save()
            
            name = request.POST['name']
            if name: # Create new field
                is_boolean = request.POST['type'].lower() == 'boolean'
                default = request.POST['default']
                if is_boolean:
                    if default.lower() in ['1','true','yes']:
                        default = '1'
                    elif default.lower() in ['0','false','no']:
                        default = '0'
                    else:
                        message(request, "Error: unrecognized default value, please enter 'yes' or 'no'.")
                        return render_template('chapadmin/edit_chapter.mako', request, chapter=c)
                else:
                    default = request.POST['default']
                f = Field()
                f.short_name = request.POST['short_name']
                f.name = name
                f.type = 0 if is_boolean else 1
                f.chapter = c
                f.default_value = default
                f.save()
            

            
        
    return render_template('chapadmin/edit_chapter.mako', request, chapter=c)


@chapter_admin_required
def chapter_email(request):
    c = request.chapter
    members = c.members_with_link().select_related('user').order_by('user__last_name')
    if request.method == 'POST':
        target = request.POST['target']
        subject = request.POST['subject']
        body = request.POST['body']
        from_email = request.user.email
        if target == 'group':
            groups = request.POST.getlist('groups')
            q = Q()
            if 'members' in groups:
                q = q | Q(is_member=True)
            if 'officers' in groups:
                q = q | Q(is_member=True, is_admin=True)
            if 'advisors' in groups:
                q = q | Q(is_member=False, is_admin=True)
            to = members.filter(q)
        if target == 'specific':
            ids = map(int, request.POST.getlist('members'))
            to = members.filter(id__in=ids)
        if target == 'field':
            field = Field.objects.get(id=int(request.POST['field']))
            qs = FieldValue.objects.filter(field=field, raw_value=request.POST['value']).select_related('user__profile')
            to = [v.user.profile for v in qs]
        
        connection = get_connection()
        from_name = '%s %s' % (request.user.first_name, request.user.last_name)
        from_email = request.user.email
        system_email = 'system@tsaevents.com'
        
        messages = []
        
        for profile in to:
            to_email = profile.user.email
            messages.append(EmailMessage(subject, body, '%s <%s>' % (from_name, system_email), [to_email],
                               headers={'Reply-To': from_email}))
            
        connection.send_messages(messages)
        
        message(request, '%d emails sent.' % len(to))
        
    return render_template('chapadmin/email.mako', request, members=members)


@login_required
def system_log(request):
    t = request.GET.get('type', 'chapter')
    if request.user.is_superuser and t == 'system':
        logs = SystemLog.objects.filter(chapter=None)
    elif request.user.is_superuser and t == 'all':
        logs = SystemLog.objects.all()
    elif request.user.profile.is_admin and t == 'chapter':
        logs = SystemLog.objects.filter(chapter=request.chapter)
    elif t == 'actions':
        logs = SystemLog.objects.filter(user=request.user)
    else:
        logs = SystemLog.objects.filter(affected=request.user)
    request.user.last_login = datetime.datetime.now()
    request.user.save()
    return render_template('system_log.mako', request, logs=logs.order_by('-date'))
    
@system_admin_required
def chapter_list(request):
    if 'switch_chapter' in request.GET:
        if request.GET['switch_chapter'] == '-1':
            request.user.profile.chapter = None
        else:
            c = Chapter.objects.get(pk=int(request.GET['switch_chapter']))
            request.user.profile.chapter = c
        request.user.profile.is_member = False
        request.user.profile.is_admin = True
        request.user.profile.save()
    return render_template('sysadmin/chapter_list.mako', request, chapters=Chapter.objects.all())
    
from django.db.models import AutoField
def copy_model_instance(obj):
    initial = dict([(f.name, getattr(obj, f.name))
                    for f in obj._meta.fields
                    if not isinstance(f, AutoField) and\
                       not f in obj._meta.parents.values()])
    return obj.__class__(**initial)

    
@system_admin_required
def eventset_list(request):
    if request.method == 'POST':
        es = EventSet.objects.get(id=int(request.POST['copy_id']))
        region = request.POST['new_region']
        ns = EventSet(region=region, state=es.state, level=es.level)
        ns.save()
        for e in es.events.all():
            ne = copy_model_instance(e)
            ne.event_set = ns
            ne.save()
        message(request, 'New event set %s created. %d events copied.' % (str(ns), ns.events.count()))
    return render_template('sysadmin/eventset_list.mako', request, evsets = EventSet.objects.all())
    
@system_admin_required
def edit_eventset(request, esid):
    es = EventSet.objects.get(id=int(esid))
    if request.method == 'POST':
        for e in es.events.all():
            max_region = int(request.POST['%d_region' % e.id])
            max_state = int(request.POST['%d_state' % e.id])
            max_nation = int(request.POST['%d_nation' % e.id])
            if e.max_region != max_region:
                e.max_region = max_region
                e.save()
                message(request, 'Regional qualification for %s updated.' % e.name)
            if e.max_state != max_state:
                qs = Event.objects.filter(name=e.name, event_set__state = es.state, event_set__level = es.level)
                qs.update(max_state=max_state)
                message(request, 'State qualification for %s updated. %d event sets affected.' % (e.name, qs.count()))
            if e.max_nation != max_nation:
                qs = Event.objects.filter(name=e.name, event_set__level = es.level)
                qs.update(max_nation=max_nation)
                message(request, 'National qualification for %s updated. %d event sets affected.' % (e.name, qs.count())) 
            
    return render_template('sysadmin/edit_eventset.mako', request, es = es)
    
    
@system_admin_required
def edit_events(request, level):
    def remove_duplicates(events):
        names = set()
        out = []
        for event in events:
            if event.name not in names:
                names.add(event.name)
                out.append(event)
        return out
        
    events = remove_duplicates(Event.objects.filter(event_set__level=level).exclude(max_nation=0))
    state_list = EventSet.objects.filter(level=level).values_list('state', flat=True)
    states = {}
    for state in state_list:
        states[state] = remove_duplicates(Event.objects.filter(event_set__level=level, event_set__state=state, max_nation=0))
    
    if request.method == 'POST':
        for event in events:
            name, short_name, min_team_size, team_size = request.POST.get('%d_name' % event.id), request.POST.get('%d_short_name' % event.id), int(request.POST.get('%d_min_team_size' % event.id)), int(request.POST.get('%d_team_size' % event.id))
            if not name or not short_name or not min_team_size or not team_size:
                continue
            if (name, short_name, min_team_size, team_size) != (event.name, event.short_name, event.min_team_size, event.team_size):
                qs = Event.objects.filter(event_set__level=event.event_set.level, name=event.name)
                num = qs.count()
                qs.update(name=name, short_name=short_name, min_team_size=min_team_size, team_size=team_size)
                message(request, '%s modified. %d events affected.' % (event.name, num))
        return HttpResponseRedirect('/config/events/%s/' % level)
    
    return render_template('sysadmin/edit_events.mako', request, national_events=events, states=states, level=level)
    
    
    
