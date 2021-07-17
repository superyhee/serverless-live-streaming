const AWS = require('aws-sdk');
const region = process.env.AWS_REGION || "cn-northwest-1";
  
const s3 = new AWS.S3({ region: region })

    

  function  getPlaylist(playlistConfig) {
        const params = {
            Bucket: playlistConfig.bucket,
            Prefix: playlistConfig.folder || ''
        };
        return new Promise((resolve, reject) => {
            s3.listObjectsV2(params, (err, data) => {
                if (err) {
                    reject(err)
                } else {
                    let playlist = s3ContentAdapter(data.Contents);
                    resolve(playlist)
                }
            })
        })
    }

  function  s3ContentAdapter(contents) {
        const chapters = [];
        for(let a = 0, item; item = contents[a]; a++) {
            let parts = item.Key.split('/');
            let title = parts[parts.length - 1]
            let chapterTitle = parts[parts.length - 2];
            let chapter;
            for ( let key in chapters) {
                if (chapters[key]['title'] == chapterTitle) {
                    chapter = chapters[key];
                }
            }
            if (!chapter) {
                chapter = {
                    title: chapterTitle,
                    items: []
                }
                chapters.push(chapter);
            }
            chapter.items.push({
                title: title.replace(/\.\w+$/, ''),
                modified: item.LastModified.toDateString(),
                size: Math.round(item.Size * .001)
            });
            

        }
        return chapters;
    }
  
    async function test() {

        let playlist;
        await getPlaylist({bucket:'video-streaming-assets-assetsbucket-gciiiklafmpb',folder:'a3569ad5-4a4a-4cf0-b9ea-6443c2cb6925/images/2021'})
            .then( response => playlist = response
               
                )
            .catch((err) => {
                throw new Error(err)
            });
        console.log(playlist)
            return playlist
        
    }
    
 
  console.log( test())

 