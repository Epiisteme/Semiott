/* var db;

class OrbitHandler {

  setUp = async () => {
    const IPFS = require('ipfs')
    const OrbitDB = require('orbit-db')

    // Create IPFS instance
    const ipfsOptions = {
      EXPERIMENTAL: {
        pubsub: true
      }
    }
    let ipfs = await IPFS.create(ipfsOptions);

    const orbitdb = await OrbitDB.createInstance(ipfs);
    const options = {
      // Give write access to everyone
      accessController: {
        write: ['*']
      }
    }
    db = await orbitdb.docstore('2-database',options);
    console.log("db address is" + db.address.toString());
    db.load();
  }

  getId = async () =>{
    const id = await db.get ('');
    const putId = id.length + 1;
    return putId;
  }

  putData = async (donor) => {
    donor._id = await this.getId();
    console.log(donor);
    db.put (donor).then ((hash) => {
      console.log (hash);
    })
  }

  getData = async () => {
    const donors = await db.get ('');
    return donors;
  }

}

export default OrbitHandler; */

var db;
class OrbitHandler {
  setUp = async () => {
    const IPFS = require('ipfs')
    const OrbitDB = require('orbit-db')
    
    // For js-ipfs >= 0.38
    
    // Create IPFS instance
    const initIPFSInstance = async () => {
      return await IPFS.create({ repo: "./path-for-js-ipfs-repo" });
    };
    
    initIPFSInstance().then(async ipfs => {
      const orbitdb = await OrbitDB.createInstance(ipfs);
      const options = {
        // Give write access to everyone
        accessController: {
          write: ['*']
        }
      }
    
      // Create / Open a database
      //const db = await orbitdb.log("hello");
      db = await orbitdb.docstore('demo2-database',options);
      console.log("db address is" + db.address.toString());
      await db.load();
    
      // Listen for updates from peers
      db.events.on("replicated", address => {
        console.log(db.iterator({ limit: -1 }).collect());
      });
    
    });
  }
  getId = async () =>{
    const id = await db.get ('');
    const putId = id.length + 1;
    return putId;
  }

  putData = async (donor) => {
    donor._id = await this.getId();
    console.log(donor);
    db.put (donor).then ((hash) => {
      console.log (hash);
    })
  }

  getData = async () => {
    const donors = await db.get ('');
    return donors;
  }
}
export default OrbitHandler;