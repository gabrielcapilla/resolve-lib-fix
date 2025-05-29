# resolve-lib-patch

Quick correction about **DaVinci Resolve** & **DaVinci Resolve Studio** related to libraries. For most people I recommend running the following command:

```sh
curl -f https://raw.githubusercontent.com/gabrielcapilla/resolve-lib-patch/main/patch.sh | sh
```

## About the error

```sh
/opt/resolve/bin/resolve: symbol lookup error: /usr/lib/libgdk_pixbuf-2.0.so.0: undefined symbol: g_task_set_static_name
```

The issue is, that resolve brings it’s own *glib2*, but not it’s own *pango*. It uses system-provided pango, which in turn assumes newer glib2 than resolve’s. The workaround is to move all glib2 libraries out of `/opt/resolve/libs` to somewhere else (`/opt/resolve/libs/_disabled`, for example). After that, resolve will pick system-provided glib2 and pango will be happy with that. The downside is, that Resolve wasn’t QA-ed with this glib2 version, so it may bug out somewhere else. On the other hand, at least it will start. Only need to move those files that belong to glib2: *libgio, libglib, libgmodule, libgobject*.

## Manual fix

Access to the location:

```sh
cd /opt/resolve/libs
```

Create the folder *_disabled* in `/opt/resolve/libs/` to move the *glib2* libraries there:

```sh
sudo mkdir --parents -- /opt/resolve/libs/_disabled
```

And then, move the glib2 inside the *_disabled* folder:

```sh
sudo mv -- libgio* libglib* libgmodule* libgobject* _disabled
```

## Source

- https://github.com/gabrielcapilla/resolve-lib-patch
