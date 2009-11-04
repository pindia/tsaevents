<%inherit file='base.mako' />

<%def name='title()'>Settings</%def>


<h3>Account Information</h3>

<table align="center">
<tr><td>Username:</td><td>${user.username}</td></tr>
<tr><td>Name:</td><td>${user.first_name} ${user.last_name}</td></tr>
<tr><td>Email:</td><td>${user.email}</td></tr>
<tr><td>Account Type:</td>
<td>
    % if not user.profile.is_member:
    Advisor
    % elif user.is_superuser:
    Administrator
    % else:
    Member
    % endif
</td></tr>
<tr><td>Chapter:</td><td>${'11/12' if user.profile.senior else '9/10'}</td></tr>
</table>

<form action="/settings" method="POST">

<h3>Email Settings</h3>

<p>
    <input type="checkbox" name="posts_email" ${'checked="yes"' if user.profile.posts_email == 2 else ''}>Send email for team posts
</p>
<input type="submit" name="action" value="Save">

<h3>Login Settings</h3>

Login URL: <a href="http://events.tsa.pindi.us${url}">Login</a> <br>

<p>
    Use this button to generate a new password and login URL.<br>
    <input type="submit" name="action" value="Regenerate Password">
</p>

</form>

