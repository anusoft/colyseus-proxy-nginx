This is a nginx (openresty) with lua script to handle colyseus loadbalance.


# Container Building
Build docker using build_docker.sh script or you can use docker-compose while you're developing to just test your configuration with just restarting container

# Caveats
Since we're unable to use init_by_lua to get current status of colyseus nodes so we have to use http endpoint to do so in this case "/healthz", redis subscribe won't work as well since it's not long-running request

When such path is called it will get current colyseus nodes then use tcp open to check if port is opened, if not it will remove from nodes list

And if you're running colyseus container such as kubernetes you'll need to update two ENVS which are SELF_HOSTNAME and SELF_PORT in index.ts

I'm using AWS ECS, to save your time here's my script.
```
async function updateSELF() {
  console.log('AWS ECS Detected');

  process.env.SELF_HOSTNAME = await getECSHostIP();
  process.env.SELF_PORT = await getECSTaskPort();
  
  console.log(`Set SELF_HOSTNAME = ${process.env.SELF_HOSTNAME}`)
  console.log(`Set SELF_PORT     = ${process.env.SELF_PORT}`)

}

async function getECSTaskPort() {
  let res = await fetch(process.env.ECS_CONTAINER_METADATA_URI_V4);
  return (await res.json()).Ports[0]['HostPort'];
}

async function getECSHostIP() {
  let res = await fetch('http://169.254.169.254/latest/meta-data/local-ipv4');
  return await res.text()
}
```