# Logging

The `syslog-ng` state is included automatically for all machines provisioned with the `elife` base state. It provides integration with Loggly as long as the related pillar enables it.

These are the standard keys that are sent with each log:
- `syslog.appName` is the name of the program generating the logs, either a off-the-shelf program or one of our projects (e.g. `nginx`, `php` but also `journal`, api-gateway`)
- `syslog.host` is the hostname being resolved to the machine(s) generating the log (e.g. `end2end--journal.elifesciences.org`)

These are the tags that are attached to each log:
- `env--{environment}` describes which environment the log has been generated in (e.g. `env--end2end`)
- `project--{project}` described the project that is deployed on the machine where the log has been generated (e.g. `project--journal`)

Additional tags can be set by a syslog-ng source with the following snippet:
```
rewrite r_myrewrite {
    set("tag=my_tagname", value("ADDITIONAL_STRUCTURED_DATA"));
};
log {
    source(s_kong_nginx_access);
    rewrite(r_myrewrite);
    destination(d_loggly);
};
```

