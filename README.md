# Terraform OpenVPN

Terraform declarations for Single node OpenVPN infrastructure

### Prerequisites

Terraform v0.11.3

Check your version.

```
terraform -v

```

### Installing

Install dependencies using `brew`.

```
brew install terraform
```

## Usage

To see how to use:

```
terraform plan
```

If everything is ok,

```
terraform apply
```

TODO: Screenshot

1. Copy the link from console and download your client configuration.
1. Copy the IP of your server from console.
1. Use these with an OpenVPN client. For example, you can use [this](https://openvpn.net/index.php/access-server/docs/admin-guides/183-how-to-connect-to-access-server-from-a-mac.html) for Mac OS X.

## Built With

* [OpenVPN](https://openvpn.net/)
* [Terraform](https://www.terraform.io/)
* [Docker](https://www.docker.com/)
* [Docker OpenVPN Image](https://hub.docker.com/r/kylemanna/openvpn/)

Special thanks to [@kylemanna](https://github.com/kylemanna) for [docker-openvpn](https://github.com/kylemanna/docker-openvpn)

## Contributing

1. Fork it!
2. Create your feature branch: `git checkout -b my-new-feature`
3. Commit your changes: `git commit -am 'Add some feature'`
4. Push to the branch: `git push origin my-new-feature`
5. Submit a pull request

## Versioning

We use [SemVer](http://semver.org/) for versioning. For the versions available, see the [tags on this repository](https://github.com/kakkoyun/terraform-openvpn/tags).

## Authors

* **Kemal Akkoyun** - *Initial work* - [kakkoyun](https://github.com/kakkoyun)

See also the list of [contributors](https://github.com/kakkoyun/terraform-openvpn/contributors) who participated in this project.

## License

This project is licensed under the GNU General Public License v3.0 - see the [LICENCE](LICENCE) file for details
