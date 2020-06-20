import React from "react";

class ReadSum extends React.Component {
  componentDidMount() {
    const { drizzle, drizzleState } = this.props;
    console.log(drizzle);
    console.log(drizzleState);
  }

render() {
    return <div>ReadSum Component</div>;
  }
}

export default ReadSum;
