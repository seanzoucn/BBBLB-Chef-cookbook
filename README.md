# BBBLoadBalancer-cookbook

You can use this cookbook to setup a BigBlueButton load balancer with Chef

## Chef cookbook

### Dependencies

- [Chef DK](https://downloads.chef.io/chef-dk/)

### BBBLoadBalancer::default

Include `BBBLoadBalancer` in your node's `run_list`:

```json
{
  "run_list": [
    "recipe[BBBLoadBalancer::default]"
  ]
}
```

## Vagrant

### dependencies

- [Chef DK](https://downloads.chef.io/chef-dk/)

### vagrant required modules

    $ vagrant plugin install vagrant-berkshelf
    $ vagrant plugin install vagrant-omnibus

### Change salt string in Vagrantfile

    chef.json = {
      bbb: {
        salt: 'ce704dc886e34675cd47630298de8022'
      }
    }

## Start Vagrant box

    $ vagrant up


## Adding BBB Servers to the load balancer

Access the web interface: http://serverip
The first time you access this page, you must create an admin user. After creating this user, you can manage the BBB load balancer. You need to add at least 1 BBB server to the list of servers before you can use the load balancer.

