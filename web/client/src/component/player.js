import React from 'react'
import ReactPlayer from 'react-player'
import './player.css'

class Player extends React.Component {
    render() {
        return (
            <div className='player-wrapper'>
                <ReactPlayer
                    url={this.props.url}
                    playsinline
                    pip
                    playing
                    controls
                    config={{
                        file: {
                            enableWorker: true,
                            enableStashBuffer: false,
                            stashInitialSize: 128,
                        },
                      }}
                />
            </div>
        )
    }
}
export default Player;
