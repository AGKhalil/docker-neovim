# Dockerized Neovim

An exercise in masochism. In an effort to have a portable development neovim
setup and learn more about docker, I've put my entire neovim setup into a docker
container. To experiment with this image you can pull it from the [docker
hub][1] repository:

```
$ docker pull thornycrackers/neovim
```

### Running the image

The image is setup internally to uid `1000`. You can check your user id with
`id -u` and if your id is different than `1000` you will have to build the
container yourself (e.g. change the `1000` numbers to your id and run `make
build`). If you want to try creating a file, say `test.txt` you could run the
following command:

```
$ docker run -i -t -v $(pwd):/src thornycrackers/neovim /bin/bash -c 'nvim /src/test.txt'
```

After you exit the neovim container your host should have the `test.txt` file
with the correct user permissions

# Step 3: Make this command a little more useful

So using that command is awesome but a little cumbersome everytime you
want to run it against a different file. Create a file called `nvim` and
make sure to give it executable permissions and place it somewhere in your
$PATH. Copy the following inside of the `nvim` executable file(make sure to
chmod +x the file)

```
#!/bin/bash
# Command for running neovim

if [[ "$1" = /* ]]; then
  file_name="$(basename ${1})"
  dir_name="$(dirname ${1})"
else
  file_name="$1"
  dir_name="$(pwd)"
fi

# Run the docker command
docker run -i -t -P -v "$dir_name":/src thornycrackers/neovim /bin/sh -c "cd /src; nvim $file_name"
```

Now you can run neovim as if you would regularly. The only gotcha I've
discovered so far is that because you are mounting to the docker
container you cannot go above the folder you open neovim in. This is
a pretty rare case in my trials of using this but it is something to note.

## NOTE:

I do set the git identity to myself inside the Dockerfile so be aware
that you might want to change it to yourself.

[1]: https://hub.docker.com/r/thornycrackers/neovim
