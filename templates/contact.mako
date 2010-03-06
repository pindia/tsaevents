<%inherit file="base.mako" />

<%def name="title()">Contact</%def>


<div align="left">

<%
if chapter.name.startswith('State High'):
    admins = user.profile.__class__.objects.filter(is_admin=True, chapter__name__startswith="State High",)
else:
    admins = chapter.members.filter(is_admin=True)
admins = admins.exclude(user__is_superuser=True)

%>
<p>
    If you are having trouble using the system, please consult the <a href="/help">help system</a> first. It contains detailed guides for both chapter members and advisors.
</p>

<p>
    If you need to have something within your chapter's system changed, contact one of your chapter officers or advisors. Their email addresses are listed below.
</p>


<h3>Chapter Officers</h3>
<ul>
% for member in admins.filter(is_member=True):
    <li>
        ${member.user.first_name} ${member.user.last_name} -
        <a href="mailto:${member.user.email}">${member.user.email}</a>
    </li>
% endfor
% if not admins.filter(is_member=True).count():
    <li><i>No chapter officers</i></li>
% endif
</ul>

<h3>Chapter Advisors</h3>
<ul>
% for member in admins.filter(is_member=False):
    <li>
        ${member.user.first_name} ${member.user.last_name} -
        <a href="mailto:${member.user.email}">${member.user.email}</a>
    </li>
% endfor
</ul>

<h3>System Administrators</h3>

For technical difficulties using the system, such as error messages or lost data, or if your chapter officers and advisors are unable to answer your question, you may contact the system administrator at <a href="mailto:admin@tsaevents.com">admin@tsaevents.com</a>.

</div>