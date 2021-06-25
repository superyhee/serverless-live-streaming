import React from 'react';
import { BrowserRouter, Route, Switch } from 'react-router-dom';
import Navbar from './navbar';
import Media from './cardmedia';
import Dns from './dnsEditor';

function App() {
  return (
      <BrowserRouter >
      <Switch>
      <Route path="/view" component={Media}/>
      <Route path="/dns" component={Dns}/>
      <Route path="/" component={Navbar}/>
      </Switch>
      </BrowserRouter>
   
  );
}

export default App;