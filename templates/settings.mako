<%inherit file='base.mako' />

<%def name='title()'>Settings</%def>

<form action="/settings" method="POST">

<h3>Account Information</h3>

<table align="center">
<tr><td>Username:</td><td>${user.username}</td></tr>
<tr><td>Name:</td><td>
<input type="entry" name="first_name" value="${user.first_name}">
<input type="entry" name="last_name" value="${user.last_name}"></td></tr>
<tr><td>Email:</td><td><input type="entry" name="email" value="${user.email}"></td></tr>
<tr><td>Account Type:</td>
<td>
    % if user.is_superuser:
    System Administrator
    % elif not user.profile.is_member:
    Advisor
    % elif user.profile.is_member:
    Administrator
    % else:
    Member
    % endif
</td></tr>
<tr><td>Chapter:</td><td>${chapter}</td></tr>
</table>

<h3>Email Settings</h3>

<p>
    <input type="checkbox" name="posts_email" ${'checked="yes"' if user.profile.posts_email == 2 else ''}>Send email for team posts
</p>
<!--<input type="submit" name="action" value="Save">-->

<h3>Login Settings</h3>

<!--Login URL: <a href="http://events.tsa.pindi.us${url}">Login</a> <br>-->

<h4>Change Password</h4>
Changing your password will invalidate all previously generated login links.
<table align="center">
<tr><td>Old:</td><td><input type="password" name="old_password"></td></tr>
<tr><td>New:</td><td><input type="password" name="new_password"></td></tr>
<tr><td>Confirm:</td><td><input type="password" name="confirm_password"></td></tr>
</table>
<input type="submit" name="action" value="Save">
<!--
<p>
    Use this button to generate a new password and login URL.<br>
    <input type="submit" name="action" value="Regenerate Password">
</p>-->

</form>

