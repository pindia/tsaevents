<%inherit file='base.mako' />

<%def name='title()'>Settings</%def>

<form action="/settings" method="POST">

<h2>Account Information</h2>

<table class="aligner layouttable">
<tr><th>Username:</th><td>${user.username}</td></tr>
<tr><th>Name:</th><td>
<input type="entry" name="first_name" value="${user.first_name}">
<input type="entry" name="last_name" value="${user.last_name}"></td></tr>
<tr><th>Email:</th><td><input type="entry" name="email" value="${user.email}"></td></tr>
<tr><th>Account Type:</th>
<td>
    % if user.is_superuser:
    System Administrator
    % elif not user.profile.is_member:
    Advisor
    % elif user.profile.is_admin:
    Officer
    % else:
    Member
    % endif
</td></tr>
<tr><th>Chapter:</th><td>${chapter}</td></tr>
</table>

% if user.profile.is_member and categories:

<h2>Fields</h2>

% for name, fields in categories.items():

    % if len(categories):
        <h3>${name}</h3>
    % endif
    <table class="aligner layouttable" style="min-width: 300px">
    % for field in fields:
        <tr>
            <td style="width:50%;"><b>${field.name}:</b></td>
            <td>
            % if field.type == 0:
                % if field.is_user_editable():
                    <input type="checkbox" name="field_${field.id}" ${'checked="yes"' if user.profile.get_field(field) else ''}>
                % else:
                    ${'Yes' if user.profile.get_field(field) else 'No'}
                % endif
            % else:
                % if field.is_user_editable():
                    <input type="entry" name="field_${field.id}" value="${user.profile.get_field(field)}">
                % else:
                    ${user.profile.get_field(field)}
                % endif
            % endif
            </td>
        </tr>
    % endfor
    </table>

% endfor

% endif

<h2>Email Settings</h2>

<p>
    <input type="checkbox" name="posts_email" ${'checked="yes"' if user.profile.posts_email == 2 else ''}>Send email for team posts
</p>

<h2>Login Settings</h2>


<h3>Change Password</h3>
<table class="layouttable aligner" style="min-width: 300px">
    <tr><th style="width:50%">Old:</th><td><input type="password" name="old_password"></td></tr>
    <tr><th>New:</th><td><input type="password" name="new_password"></td></tr>
    <tr><th>Confirm:</th><td><input type="password" name="confirm_password"></td></tr>
</table>

<p><input type="submit" name="action" value="Save"></p>


</form>

