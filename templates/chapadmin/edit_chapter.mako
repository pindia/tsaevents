<%inherit file='../base.mako' />

<%def name='title()'>Edit Chapter</%def>
<%
def sel(cond):
    return 'selected="yes"' if cond else ''

%>

<h2>Chapter Information</h2>

<table class="aligner">
    <tr><th>Name:</th><td>${chapter.name}</td></tr>
    % if chapter.link:
        <tr><td><i>Master:</i></td><td><i>${chapter.link.name}</i></td>
    % endif
    <tr><th>Members:</th><td>${chapter.members.filter(is_member=True).count()}</td></tr>
    <tr><th>Teams:</th><td>${chapter.teams.count()}</td></tr>
</table>

<form method="post" action="/edit_chapter">

<h2>Chapter Settings</h2>

<table class="layouttable aligner">
    <tr>
        <th>Chapter ID:</th>
        <td>
            <input type="entry" name="chapter_id" value=${chapter.chapter_id}><br>
            <span style="font-size:smaller;">Prefix for all IDs; like <b>2045</b>-xxxx</span>
        </td>
    </tr>
    <tr>
        <th>Allow new users:</th>
        <td><input type="checkbox" name="register_open" ${'checked="yes"' if chapter.register_open else ''}></td>
    </tr>
    <tr>
        <th>Key:</th>
        <td>
            <input type="entry" name="key" value=${chapter.key}><br>
            <span style="font-size:smaller;">Optional; new users must enter this key to register</span>
        </td>
    </tr>
    <tr>
        <th>Info:</th>
        <td>
            <textarea name="info" style="width:300px; height:100px;">${chapter.info}</textarea><br>
            <span style="font-size:smaller;">Displayed to new users on registration screen</span>
        </td>
    </tr>
    <tr>
        <th>Message:</th>
        <td>
            <textarea name="message" style="width:300px; height:100px;">${chapter.message}</textarea><br>
            <span style="font-size:smaller;">Displayed to chapter members on the front page</span>
        </td>
    </tr>

</table>



% if chapter.link:
    Switch to master chapter to view and edit fields.
% else:

<h2>Fields</h2>
<table align="center" class="tabular_list">
    <tr>
        <th>Name</th>
        <th>Short Name</th>
        <th>Category</th>
        <th>Weight</th>
        <th>Who may view?</th>
        <th>Who may edit?</th>
        <th>Type</th>
        <th>Default</th>
    </tr>
    % for field in chapter.get_fields():
    <tr>
        <td><input type="entry" size="15" name="${field.id}_name" value="${field.name}"></td>
        <td><input type="entry" size="6" name="${field.id}_short_name" value="${field.short_name}"></td>
        <td><input type="entry" size="6" name="${field.id}_category" value="${field.category}"></td>
        <td><input type="entry" size="2" name="${field.id}_weight" value="${field.weight}"></td>
        
        <td>
            <select name="${field.id}_view_perm">
                <option value="0" ${sel(field.view_perm == 0)}>Admin only</option>
                <option value="1" ${sel(field.view_perm == 1)}>Admin or user</option>
            </select>
        </td>
        <td>
            <select name="${field.id}_edit_perm">
                <option value="3" disabled ${sel(field.edit_perm == 3)}>Editing locked</option>
                <option value="2" disabled ${sel(field.edit_perm == 2)}>Admin only (logged)</option>
                <option value="0" ${sel(field.edit_perm == 0)}>Admin only</option>
                <option value="1" disabled ${sel(field.edit_perm == 1)}>Admin or user</option>
            </select>
        </td>
        
        <td>${field.get_type_display()}</td>
        <td>${field.format_value(field.default_value)}</td>
    </tr>
    % endfor
</table>

<h3>New Field</h3>
    <table class="layouttable aligner">
        <tr><td>Name:</td><td><input type="entry" name="name"></td></tr>
        <tr><td>Short Name:</td><td><input type="entry" name="short_name"></td></tr>
        <tr><td>Type:</td><td>
        <select name="type">
            <option value="text">Text</option>
            <option value="boolean">Boolean (Yes/No)</option>
        </select></td></tr>
        <tr><td>Default:</td><td><input type="entry" name="default"></td>
    </table>
% endif


<input type="submit" value="Submit">

</form>